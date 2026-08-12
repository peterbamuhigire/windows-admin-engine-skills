#!/usr/bin/env python3
"""Zero-debt structural validator for the Windows skill engine."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "python"))

from windows_admin.catalog import load_catalog, load_json_yaml  # noqa: E402

REQUIRED_SECTIONS = (
    "Use when", "Do not use when", "Inputs", "Platform and privilege boundary",
    "Workflow", "Mutation, verification, and recovery", "Stop conditions",
    "Capability contract and degraded mode", "Outputs",
    "Decision rules", "Quality standards", "Anti-patterns", "References",
)


def frontmatter(text: str) -> tuple[str | None, str | None]:
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not match:
        return None, None
    name = re.search(r"^name:\s*(.+)$", match.group(1), re.MULTILINE)
    description = re.search(r"^description:\s*(.+)$", match.group(1), re.MULTILINE)
    return (name.group(1).strip() if name else None, description.group(1).strip() if description else None)


def main() -> int:
    errors: list[str] = []
    try:
        skills = load_catalog(REPO)
        source_ids = {item["id"] for item in load_json_yaml(REPO / "engine" / "source-register.yaml").get("sources", [])}
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 1
    for skill in skills:
        path = REPO / skill.path
        if not path.is_file():
            errors.append(f"missing skill: {skill.path}")
            continue
        text = path.read_text(encoding="utf-8-sig")
        name, description = frontmatter(text)
        if name != skill.id:
            errors.append(f"{skill.path}: frontmatter name {name!r} != {skill.id!r}")
        if not description or not description.startswith("Use when"):
            errors.append(f"{skill.path}: description must start with 'Use when'")
        if len(text.splitlines()) > 500:
            errors.append(f"{skill.path}: exceeds 500 lines")
        for section in REQUIRED_SECTIONS:
            if not re.search(rf"^## {re.escape(section)}\s*$", text, re.MULTILINE | re.IGNORECASE):
                errors.append(f"{skill.path}: missing section '{section}'")
        missing_sources = set(skill.sources) - source_ids
        if missing_sources:
            errors.append(f"{skill.id}: unknown source ids {sorted(missing_sources)}")
    catalogue_paths = {skill.path for skill in skills}
    actual = {path.relative_to(REPO).as_posix() for path in REPO.glob("[0-9][0-9]-*/**/SKILL.md")}
    unlisted = actual - catalogue_paths
    if unlisted:
        errors.append(f"unlisted specialist skills: {sorted(unlisted)}")
    for required in ("AGENTS.md", "windows-sysadmin/SKILL.md", "engine/catalog.schema.json", "engine/schemas/operation-envelope.schema.json"):
        if not (REPO / required).is_file():
            errors.append(f"missing required artifact: {required}")
    for error in errors:
        print(f"ERROR: {error}")
    print(f"validated_skills={len(skills)} findings={len(errors)}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
