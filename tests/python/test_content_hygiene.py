import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
sys.path.insert(0, str(ROOT / 'python'))
from check_content_hygiene import audit_references  # noqa: E402


def skill(skill_id):
    return {
        'id': skill_id, 'path': f'skills/x/{skill_id}/SKILL.md', 'category': 'x', 'trigger': 't',
        'exclusions': [], 'dependencies': [], 'platforms': [], 'risk_class': 'R0',
        'script_tier': 'read-only', 'maturity': 'PARTIAL', 'owner': 'o', 'last_verified': '2026-01-01',
        'sources': [], 'keywords': ['k'],
    }


class ReferenceTests(unittest.TestCase):
    def repo(self, files):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        (root / 'engine').mkdir()
        (root / 'engine/catalog.yaml').write_text(json.dumps(
            {'schema_version': '1.0', 'skills': [skill('windows-alpha')]}))
        for name, text in files.items():
            (root / name).parent.mkdir(parents=True, exist_ok=True)
            (root / name).write_text(text, encoding='utf-8')
        return root

    def findings(self, files):
        return audit_references(self.repo(files), sorted(files))

    def test_broken_link_is_reported_with_file_and_line(self):
        found = self.findings({'docs/a.md': 'ok\n[gone](missing.md)\n'})
        self.assertEqual(['docs/a.md:2: link does not resolve: missing.md'], found)

    def test_resolving_file_directory_and_fragment_links_pass(self):
        found = self.findings({
            'docs/a.md': '[b](b.md#top) [dir](sub/) [self](#here) [web](https://example.org/x) [m](mailto:a@b.c)\n',
            'docs/b.md': 'b\n', 'docs/sub/c.md': 'c\n'})
        self.assertEqual([], found)

    def test_links_in_code_are_not_followed(self):
        text = '```\n[a](nope.md)\n```\nInline `[b](nope.md)` is code.\n~~~\n[c](nope.md)\n~~~\n'
        self.assertEqual([], self.findings({'docs/a.md': text}))

    def test_link_after_a_closed_fence_is_checked_again(self):
        found = self.findings({'docs/a.md': '```\nx\n```\n[a](nope.md)\n'})
        self.assertEqual(1, len(found))

    def test_unknown_skill_identifier_is_reported(self):
        found = self.findings({'docs/a.md': 'Route to `windows-beta` first.\n'})
        self.assertEqual(['docs/a.md:1: unknown skill identifier windows-beta'], found)

    def test_catalogue_hub_and_named_non_skill_identifiers_pass(self):
        text = 'windows-alpha, windows-sysadmin, windows-admin, windows-server, windows-latest.\n'
        self.assertEqual([], self.findings({'docs/a.md': text}))

    def test_identifier_must_match_whole_token(self):
        found = self.findings({'docs/a.md': 'windows-alpha-extra and windows-alph\n'})
        self.assertEqual(2, len(found))

    def test_planned_and_evidence_trees_are_exempt_from_identifiers_only(self):
        found = self.findings({
            'docs/plans/p.md': 'needs windows-event-logs\n[x](missing.md)\n',
            'docs/kaizen/k.md': 'defect windows-identity-ad\n'})
        self.assertEqual(['docs/plans/p.md:2: link does not resolve: missing.md'], found)

    def test_non_markdown_files_are_ignored(self):
        self.assertEqual([], self.findings({'docs/a.json': '"windows-beta" [x](nope.md)'}))

    def test_live_repository_has_no_reference_findings(self):
        self.assertEqual([], audit_references(ROOT))


if __name__ == '__main__':
    unittest.main()
