import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import check_marketplace
from check_marketplace import audit_repository, capacity_findings, count_files


class MarketplaceTests(unittest.TestCase):
    def fixture(self, root):
        (root / 'skills/one').mkdir(parents=True)
        (root / 'skills/one/SKILL.md').write_text('---\nname: one\n---\n')
        (root / '.claude-plugin').mkdir()
        self.write(root, 'plugin.json', {'name': 'test', 'version': '1.0.0', 'skills': ['./skills/one/']})
        self.write(root, 'marketplace.json', {'plugins': [{'name': 'test', 'version': '1.0.0', 'source': './'}]})
        for file in ('AGENTS.md', 'README.md'):
            (root / file).write_text('Resolve engines through the catalogue.\n')

    def write(self, root, name, data):
        (root / '.claude-plugin' / name).write_text(json.dumps(data))

    def test_boundary_is_fixed_at_five_thousand(self):
        self.assertEqual([], capacity_findings(5000, 5000))
        self.assertEqual(1, len(capacity_findings(5001, 5000)))
        self.assertEqual(1, len(capacity_findings(5000, 5001)))

    def test_full_inventory_keeps_git_and_caches(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            before = count_files(root, package=True)
            for name in ('.git', '__pycache__'):
                (root / name).mkdir()
                (root / name / 'entry').write_text('fixture')
            self.assertEqual(before, count_files(root, package=True))
            self.assertEqual(before + 2, count_files(root, package=False))

    def test_full_and_package_counts_include_directory_symlinks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / 'target'
            target.mkdir()
            before_full = count_files(root, package=False)
            before_package = count_files(root, package=True)
            try:
                (root / 'linked-directory').symlink_to(target, target_is_directory=True)
            except OSError as error:
                self.skipTest(f'directory symlink creation unavailable: {error}')
            self.assertEqual(before_full + 1, count_files(root, package=False))
            self.assertEqual(before_package + 1, count_files(root, package=True))

    def test_unreadable_subtree_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)

            def broken_walk(path, *, followlinks, onerror):
                self.assertFalse(followlinks)
                onerror(PermissionError('fixture: unreadable subtree'))
                yield  # pragma: no cover - onerror must abort the inventory

            with patch.object(check_marketplace.os, 'walk', broken_walk):
                with self.assertRaisesRegex(PermissionError, 'unreadable subtree'):
                    count_files(root, package=False)

    def test_identity_duplicate_and_path_escape_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            self.assertEqual([], audit_repository(root)[0])
            for paths in (['../outside'], ['./skills/missing/'], ['./skills/one/', './skills/one/'], []):
                with self.subTest(paths=paths):
                    self.write(root, 'plugin.json', {'name': 'test', 'version': '1.0.0', 'skills': paths})
                    self.assertTrue(audit_repository(root)[0])
            self.write(root, 'plugin.json', {'name': 'different', 'version': '1.0.0', 'skills': ['./skills/one/']})
            self.assertTrue(any('identity' in finding for finding in audit_repository(root)[0]))

    def test_symlinked_skill_is_not_followed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            try:
                (root / 'skills/link').symlink_to(root / 'skills/one', target_is_directory=True)
            except OSError as error:
                self.skipTest(f'symlink creation unavailable: {error}')
            self.write(root, 'plugin.json', {'name': 'test', 'version': '1.0.0', 'skills': ['./skills/link/']})
            self.assertTrue(any('linked' in finding for finding in audit_repository(root)[0]))

    def test_document_cannot_become_accidental_slash_command(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            (root / 'commands').mkdir()
            (root / 'commands/README.md').write_text('Operator documentation')
            self.assertTrue(any('unintended Claude' in finding for finding in audit_repository(root)[0]))

    def test_machine_binding_and_unreadable_manifest_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            (root / 'AGENTS.md').write_text(r'Read C:\wamp64\www\another-engine.')
            self.assertTrue(any('machine-specific' in finding for finding in audit_repository(root)[0]))
            (root / '.claude-plugin/plugin.json').write_text('{')
            self.assertTrue(any('cannot validate' in finding for finding in audit_repository(root)[0]))


if __name__ == '__main__':
    unittest.main()
