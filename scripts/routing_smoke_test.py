#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "python"))
from windows_admin.catalog import load_catalog  # noqa: E402
from windows_admin.router import rank  # noqa: E402


def main() -> int:
    skills = load_catalog(REPO)
    fixtures = json.loads((REPO / "tests" / "fixtures" / "routing.json").read_text(encoding="utf-8"))
    failures = []
    for fixture in fixtures:
        routes = rank(fixture["prompt"], skills)
        actual = [route.skill.id for route in routes]
        if fixture["expected"] not in actual[:3]:
            failures.append({"prompt": fixture["prompt"], "expected": fixture["expected"], "actual": actual})
    for failure in failures:
        print("FAIL " + json.dumps(failure))
    print(f"routing_fixtures={len(fixtures)} failures={len(failures)}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
