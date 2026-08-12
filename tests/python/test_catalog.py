from pathlib import Path
import sys
import unittest

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "python"))

from windows_admin.catalog import load_catalog


class CatalogTests(unittest.TestCase):
    def test_catalogue_has_unique_existing_skills(self):
        skills = load_catalog(REPO)
        self.assertEqual(len(skills), len({skill.id for skill in skills}))
        self.assertGreaterEqual(len(skills), 16)

    def test_risk_classes_are_explicit(self):
        self.assertTrue(all(skill.risk_class.startswith("R") for skill in load_catalog(REPO)))


if __name__ == "__main__":
    unittest.main()
