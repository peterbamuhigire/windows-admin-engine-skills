#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "python"))
from windows_admin.catalog import load_catalog  # noqa: E402
from windows_admin.router import rank  # noqa: E402


# Specialists with at least three positives and two owned negatives (a negative is
# owned by each skill in its forbidden_primary list). Raise this when coverage grows;
# lowering it needs a stated reason, because it means fixtures were removed.
FULL_COVERAGE_FLOOR = 11
MIN_POSITIVES = 3
MIN_OWNED_NEGATIVES = 2


def covered_skills(fixtures: list[dict], skill_ids: list[str]) -> list[str]:
    positives: Counter[str] = Counter()
    owned_negatives: Counter[str] = Counter()
    for fixture in fixtures:
        if fixture.get("kind") == "negative":
            owned_negatives.update(fixture.get("forbidden_primary", []))
        else:
            positives[fixture["expected"]] += 1
    return [skill_id for skill_id in skill_ids
            if positives[skill_id] >= MIN_POSITIVES and owned_negatives[skill_id] >= MIN_OWNED_NEGATIVES]


def main() -> int:
    skills = load_catalog(REPO)
    fixtures = json.loads((REPO / "tests" / "fixtures" / "routing.json").read_text(encoding="utf-8"))
    failures = []
    at_one = 0
    negative_count = 0
    negative_passed = 0
    for fixture in fixtures:
        routes = rank(fixture["prompt"], skills)
        actual = [route.skill.id for route in routes]
        at_one += int(bool(actual) and actual[0] == fixture["expected"])
        if fixture.get("kind") == "negative":
            negative_count += 1
            negative_passed += int(bool(actual) and actual[0] == fixture["expected"] and actual[0] not in fixture.get("forbidden_primary", []))
        if fixture.get("expected_rank") == 1 and (not actual or actual[0] != fixture["expected"]):
            failures.append({"prompt": fixture["prompt"], "expected_first": fixture["expected"], "actual": actual})
        if actual and actual[0] in fixture.get("forbidden_primary", []):
            failures.append({"prompt": fixture["prompt"], "forbidden_primary": actual[0]})
        if fixture["expected"] not in actual[:3]:
            failures.append({"prompt": fixture["prompt"], "expected": fixture["expected"], "actual": actual})
    covered = covered_skills(fixtures, [skill.id for skill in skills])
    if len(covered) < FULL_COVERAGE_FLOOR:
        failures.append({"fixture_coverage_below_floor": len(covered), "floor": FULL_COVERAGE_FLOOR})
    for failure in failures:
        print("FAIL " + json.dumps(failure))
    print(f"routing_fixtures={len(fixtures)} failures={len(failures)}")
    print(f"fixture_coverage={len(covered)}/{len(skills)} specialists with >={MIN_POSITIVES} positives and >={MIN_OWNED_NEGATIVES} owned negatives (floor {FULL_COVERAGE_FLOOR})")
    print(f"precision_at_1={at_one}/{len(fixtures)} owned_negative_primary={negative_passed}/{negative_count}; lexical proxy, not model behaviour")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
