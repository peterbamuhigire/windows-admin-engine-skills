"""Regression contract for the book-wave Windows-engine improvements."""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
REFERENCE = ROOT / "docs" / "research" / "book-driven-kaizen-operating-system.md"
TARGETS = {
    "skills/windows-sysadmin/SKILL.md": "book-driven-kaizen-operating-system.md",
    "skills/fleet-hybrid-and-management-planes/windows-fleet-management/SKILL.md": "book-driven-kaizen-operating-system.md",
    "skills/backup-recovery-and-business-continuity/windows-backup-recovery/SKILL.md": "book-driven-kaizen-operating-system.md",
    "skills/policy-security-and-compliance/windows-security-analysis/SKILL.md": "book-driven-kaizen-operating-system.md",
}


class BookWaveKaizenContractTests(unittest.TestCase):
    def test_reference_exists_and_covers_operating_contract(self):
        self.assertTrue(REFERENCE.is_file(), REFERENCE)
        text = REFERENCE.read_text(encoding="utf-8").lower()
        for phrase in (
            "Aim, measures, and PDSA",
            "repeatable core and bounded adaptation",
            "fleet scenario and sensitivity",
            "learning transfer",
            "agent decision rights and recovery",
            "currentness gate",
        ):
            self.assertIn(phrase.lower(), text)

    def test_high_leverage_skills_link_the_reference(self):
        for relative, link_text in TARGETS.items():
            skill = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(link_text, skill, relative)


if __name__ == "__main__":
    unittest.main()
