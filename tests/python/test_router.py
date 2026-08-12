from pathlib import Path
import json
import sys
import unittest

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "python"))

from windows_admin.catalog import load_catalog
from windows_admin.router import rank


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

    def test_blank_prompt_has_no_route(self):
        self.assertEqual(rank("", self.skills), [])


if __name__ == "__main__":
    unittest.main()
