from pathlib import Path
import json
import sys
import unittest

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "python"))
sys.path.insert(0, str(REPO / "scripts"))

from windows_admin.catalog import load_catalog
from windows_admin.router import rank
from routing_smoke_test import FULL_COVERAGE_FLOOR, covered_skills


class RouterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.skills = load_catalog(REPO)

    def test_all_fixtures_route_in_top_three(self):
        fixtures = json.loads((REPO / "tests/fixtures/routing.json").read_text(encoding="utf-8"))
        for fixture in fixtures:
            with self.subTest(prompt=fixture["prompt"]):
                actual = [route.skill.id for route in rank(fixture["prompt"], self.skills)]
                self.assertIn(fixture["expected"], actual[:3])
                if fixture.get("expected_rank") == 1:
                    self.assertEqual(fixture["expected"], actual[0])
                self.assertNotIn(actual[0], fixture.get("forbidden_primary", []))

    def test_coverage_counts_owned_negatives_by_forbidden_skill(self):
        positives = [{"prompt": str(i), "expected": "a", "kind": "positive"} for i in range(3)]
        owned = [{"prompt": "n1", "expected": "b", "kind": "negative", "forbidden_primary": ["a"]},
                 {"prompt": "n2", "expected": "c", "kind": "negative", "forbidden_primary": ["a", "b"]}]
        self.assertEqual(["a"], covered_skills(positives + owned, ["a", "b", "c"]))
        self.assertEqual([], covered_skills(positives + owned[:1], ["a", "b", "c"]))
        self.assertEqual([], covered_skills(positives[:2] + owned, ["a", "b", "c"]))
        # The negative's expected skill does not own it: "b" has one owned negative and no positives.
        self.assertNotIn("c", covered_skills(positives + owned, ["a", "b", "c"]))

    def test_live_fixtures_meet_the_coverage_floor(self):
        fixtures = json.loads((REPO / "tests/fixtures/routing.json").read_text(encoding="utf-8"))
        self.assertGreaterEqual(len(covered_skills(fixtures, [skill.id for skill in self.skills])), FULL_COVERAGE_FLOOR)

    def test_blank_prompt_has_no_route(self):
        self.assertEqual(rank("", self.skills), [])


if __name__ == "__main__":
    unittest.main()
