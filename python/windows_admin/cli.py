"""Command-line interface for routing and structural validation."""

from __future__ import annotations

import argparse
import json
import os
import platform
import subprocess
import sys
from dataclasses import asdict
from pathlib import Path

from .catalog import load_catalog
from .router import authority_warning, rank
from .schemas import validate_evidence_pack, validate_operation


def _repo(value: str) -> Path:
    path = Path(value).resolve()
    if not (path / "engine" / "catalog.yaml").is_file():
        raise argparse.ArgumentTypeError(f"not an engine root: {path}")
    return path


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="windows-admin", description="Windows Administration Skills Engine CLI")
    parser.add_argument("--repo", type=_repo, default=Path.cwd(), help="engine repository root")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list", help="list catalogue skills")
    route_parser = sub.add_parser("route", help="rank skills for an operator request")
    route_parser.add_argument("prompt")
    route_parser.add_argument("--json", action="store_true")
    validate_parser = sub.add_parser("validate-operation", help="validate an operation JSON file")
    validate_parser.add_argument("path", type=Path)
    evidence_parser = sub.add_parser("validate-evidence", help="validate an evidence-pack directory")
    evidence_parser.add_argument("path", type=Path)
    sub.add_parser("doctor", help="report local runtime and gate availability")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    repo = args.repo.resolve()
    if args.command == "list":
        for skill in load_catalog(repo):
            print(f"{skill.id:38} {skill.risk_class} {skill.maturity:14} {skill.category}")
        return 0
    if args.command == "route":
        routes = rank(args.prompt, load_catalog(repo))
        if args.json:
            payload = [{"id": r.skill.id, "score": r.score, "risk": r.skill.risk_class, "maturity": r.skill.maturity, "reasons": r.reasons} for r in routes]
            print(json.dumps({"routes": payload, "warning": authority_warning(args.prompt, routes[0] if routes else None)}, indent=2))
        else:
            for index, route in enumerate(routes, 1):
                print(f"{index}. {route.skill.id} score={route.score} risk={route.skill.risk_class} maturity={route.skill.maturity}")
            warning = authority_warning(args.prompt, routes[0] if routes else None)
            if warning:
                print(f"warning: {warning}")
        return 0 if routes else 2
    if args.command == "validate-operation":
        data = json.loads(args.path.read_text(encoding="utf-8-sig"))
        errors = validate_operation(data)
    elif args.command == "validate-evidence":
        errors = validate_evidence_pack(args.path)
    elif args.command == "doctor":
        print(json.dumps({
            "engine": "0.1.0", "python": sys.version.split()[0],
            "platform": platform.platform(), "powershell_edition": os.environ.get("PSEDITION", "unknown"),
            "repo": str(repo), "catalogue_skills": len(load_catalog(repo)),
            "live_windows_lab": "NOT_ASSESSED",
        }, indent=2))
        return 0
    else:
        return 2
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
