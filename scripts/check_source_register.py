#!/usr/bin/env python3
"""Release gate: fail when a source-register row is undated or past its review interval.

engine/source-register.yaml declares policy.review_interval_days. This script
applies it. It reads dates only; it makes no network request and does not judge
whether a source supports a claim (see verify_source_urls.py for liveness).
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
REGISTER = REPO / "engine" / "source-register.yaml"
WARN_WITHIN_DAYS = 14

STATUS_VOCABULARY = {
    "current-check-required", "currentness-check-required", "historical-only",
    "verify-every-command", "do-not-execute-directly", "stable-concepts-current-apis-verified",
    "partial-edition", "verify-tool-version", "verified-scoped",
}


def parse_day(value: object) -> date | None:
    if not isinstance(value, str):
        return None
    try:
        return date.fromisoformat(value)
    except ValueError:
        return None


def audit_register(register: dict, as_of: date) -> tuple[list[str], list[str], dict[str, int]]:
    """Return (findings, warnings, counts) for one register at the given day."""
    findings: list[str] = []
    warnings: list[str] = []
    counts = {"rows": 0, "url_rows": 0, "expired": 0, "lapsing": 0}
    policy = register.get("policy") if isinstance(register.get("policy"), dict) else {}
    interval = policy.get("review_interval_days")
    if type(interval) is not int or interval < 1:
        return ["policy.review_interval_days must be a positive integer"], warnings, counts
    for key, value in policy.items():
        if key.endswith("_review_date"):
            due = parse_day(value)
            if due is None:
                findings.append(f"policy.{key} is not an ISO date: {value!r}")
            elif due < as_of:
                findings.append(f"policy.{key} {due} has passed (as of {as_of})")
    rows = register.get("sources")
    if not isinstance(rows, list) or not rows:
        return findings + ["sources must be a non-empty list"], warnings, counts
    for row in rows:
        counts["rows"] += 1
        ident = row.get("id", "<no id>") if isinstance(row, dict) else "<not an object>"
        if not isinstance(row, dict) or not row.get("id"):
            findings.append(f"{ident}: row needs an id")
            continue
        if row.get("status") not in STATUS_VOCABULARY:
            findings.append(f"{ident}: unknown status {row.get('status')!r}")
        if not row.get("url"):
            continue
        counts["url_rows"] += 1
        stamps = {name: parse_day(row.get(name)) for name in ("accessed", "verified") if name in row}
        if parse_day(row.get("accessed")) is None:
            findings.append(f"{ident}: URL row needs an ISO accessed date")
            continue
        if "verified" in stamps and stamps["verified"] is None:
            findings.append(f"{ident}: verified is not an ISO date: {row['verified']!r}")
            continue
        newest = max(day for day in stamps.values() if day is not None)
        if newest > as_of:
            findings.append(f"{ident}: date {newest} is after {as_of}")
            continue
        lapse = newest + timedelta(days=interval)
        if as_of > lapse:
            counts["expired"] += 1
            findings.append(f"{ident}: last dated {newest}, past the {interval}-day interval since {lapse}")
        elif as_of + timedelta(days=WARN_WITHIN_DAYS) >= lapse:
            counts["lapsing"] += 1
            warnings.append(f"{ident}: review interval ends {lapse}")
    return findings, warnings, counts


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--as-of", help="ISO date to evaluate against (default: today, UTC)")
    parser.add_argument("--register", type=Path, default=REGISTER)
    args = parser.parse_args(argv)
    as_of = parse_day(args.as_of) if args.as_of else datetime.now(timezone.utc).date()
    if as_of is None:
        print("ERROR: --as-of must be an ISO date", file=sys.stderr)
        return 2
    try:
        register = json.loads(args.register.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read register: {exc}", file=sys.stderr)
        return 2
    if not isinstance(register, dict):
        print("ERROR: register root must be an object", file=sys.stderr)
        return 2
    findings, warnings, counts = audit_register(register, as_of)
    for line in warnings:
        print(f"WARN: {line}")
    for line in findings:
        print(f"ERROR: {line}")
    print(f"as_of={as_of} rows={counts['rows']} url_rows={counts['url_rows']} "
          f"expired={counts['expired']} lapsing_within_{WARN_WITHIN_DAYS}_days={counts['lapsing']} "
          f"findings={len(findings)}")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
