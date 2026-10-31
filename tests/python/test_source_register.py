import contextlib
import copy
import io
import json
import sys
import tempfile
import unittest
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from check_source_register import STATUS_VOCABULARY, WARN_WITHIN_DAYS, audit_register, main  # noqa: E402

DAY = date(2026, 10, 31)


def register(**row_overrides):
    row = {'id': 'MS-ONE', 'tier': 1, 'title': 't', 'url': 'https://example.org/a', 'scope': 's',
           'status': 'current-check-required', 'accessed': '2026-08-12'}
    row.update(row_overrides)
    return {'policy': {'review_interval_days': 90}, 'sources': [row]}


class SourceRegisterTests(unittest.TestCase):
    def test_fresh_row_passes_without_warning(self):
        findings, warnings, counts = audit_register(register(accessed='2026-10-01'), DAY)
        self.assertEqual(([], []), (findings, warnings))
        self.assertEqual({'rows': 1, 'url_rows': 1, 'expired': 0, 'lapsing': 0}, counts)

    def test_interval_boundary_is_inclusive_then_expired_the_next_day(self):
        # 2026-08-12 plus 90 days is 2026-11-10.
        self.assertEqual([], audit_register(register(), date(2026, 11, 10))[0])
        findings, _, counts = audit_register(register(), date(2026, 11, 11))
        self.assertEqual(1, counts['expired'])
        self.assertIn('MS-ONE: last dated 2026-08-12, past the 90-day interval since 2026-11-10', findings)

    def test_row_lapsing_soon_warns_but_does_not_fail(self):
        findings, warnings, counts = audit_register(register(), DAY)
        self.assertEqual([], findings)
        self.assertEqual(['MS-ONE: review interval ends 2026-11-10'], warnings)
        self.assertEqual(1, counts['lapsing'])
        self.assertEqual(14, WARN_WITHIN_DAYS)

    def test_verified_date_extends_the_interval(self):
        self.assertEqual([], audit_register(register(verified='2026-10-31'), date(2026, 12, 1))[0])
        self.assertEqual(1, len(audit_register(register(verified='2026-10-31'), date(2027, 2, 1))[0]))

    def test_url_row_needs_a_valid_accessed_date(self):
        row = register()
        del row['sources'][0]['accessed']
        self.assertEqual(['MS-ONE: URL row needs an ISO accessed date'], audit_register(row, DAY)[0])
        for bad in ('12/08/2026', '2026-13-40', '', None, 20260812):
            with self.subTest(bad=bad):
                self.assertEqual(['MS-ONE: URL row needs an ISO accessed date'],
                                 audit_register(register(accessed=bad), DAY)[0])

    def test_invalid_or_future_verified_and_accessed_dates_fail(self):
        self.assertTrue(audit_register(register(verified='soon'), DAY)[0])
        self.assertTrue(audit_register(register(accessed='2027-01-01'), DAY)[0])
        self.assertTrue(audit_register(register(verified='2027-01-01'), DAY)[0])

    def test_book_rows_need_no_accessed_date_but_need_a_known_status(self):
        book = {'id': 'BOOK-X', 'tier': 4, 'title': 't', 'author': 'a', 'scope': 's', 'status': 'historical-only'}
        data = {'policy': {'review_interval_days': 90}, 'sources': [book]}
        self.assertEqual([], audit_register(data, DAY)[0])
        data['sources'][0]['status'] = 'probably-fine'
        self.assertEqual(["BOOK-X: unknown status 'probably-fine'"], audit_register(data, DAY)[0])

    def test_status_vocabulary_covers_the_live_register(self):
        live = json.loads((ROOT / 'engine/source-register.yaml').read_text(encoding='utf-8'))
        self.assertLessEqual({row['status'] for row in live['sources']}, STATUS_VOCABULARY)

    def test_interval_must_be_a_positive_integer(self):
        for bad in (None, 0, -5, '90', True, 1.5):
            with self.subTest(bad=bad):
                data = register()
                data['policy']['review_interval_days'] = bad
                self.assertEqual(['policy.review_interval_days must be a positive integer'], audit_register(data, DAY)[0])

    def test_row_review_by_date_is_checked(self):
        self.assertEqual([], audit_register(register(accessed='2026-10-30', review_by='2026-10-31'), DAY)[0])
        self.assertEqual(['MS-ONE: review_by 2026-10-30 has passed (as of 2026-10-31)'],
                         audit_register(register(accessed='2026-10-30', review_by='2026-10-30'), DAY)[0])
        self.assertEqual(["MS-ONE: review_by is not an ISO date: 'later'"],
                         audit_register(register(accessed='2026-10-30', review_by='later'), DAY)[0])
        book = {'id': 'BOOK-X', 'tier': 4, 'status': 'historical-only', 'review_by': '2026-01-01'}
        data = {'policy': {'review_interval_days': 90}, 'sources': [book]}
        self.assertEqual(['BOOK-X: review_by 2026-01-01 has passed (as of 2026-10-31)'], audit_register(data, DAY)[0])

    def test_policy_review_dates_are_checked(self):
        data = register(accessed='2026-10-30')
        data['policy']['next_review_date'] = '2026-10-30'
        self.assertEqual(1, len(audit_register(data, DAY)[0]))
        data['policy']['next_review_date'] = '2026-10-31'
        self.assertEqual([], audit_register(data, DAY)[0])
        data['policy']['next_review_date'] = 'November'
        self.assertEqual(1, len(audit_register(data, DAY)[0]))

    def test_empty_or_malformed_sources_fail(self):
        for sources in ([], None, 'x'):
            with self.subTest(sources=sources):
                data = register()
                data['sources'] = sources
                self.assertTrue(audit_register(data, DAY)[0])
        data = register()
        data['sources'].append('not an object')
        data['sources'].append({'status': 'historical-only'})
        self.assertEqual(2, len(audit_register(data, DAY)[0]))

    def test_live_register_passes_on_the_cycle_date(self):
        live = json.loads((ROOT / 'engine/source-register.yaml').read_text(encoding='utf-8'))
        self.assertEqual([], audit_register(live, DAY)[0])

    def run_main(self, data, *args):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'register.json'
            path.write_text(json.dumps(data))
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                code = main(['--register', str(path), *args])
            return code, out.getvalue()

    def test_cli_exit_codes_and_summary(self):
        code, out = self.run_main(register(), '--as-of', '2026-10-31')
        self.assertEqual(0, code)
        self.assertIn('WARN: MS-ONE', out)
        self.assertIn('expired=0 lapsing_within_14_days=1 findings=0', out)
        code, out = self.run_main(copy.deepcopy(register()), '--as-of', '2026-11-11')
        self.assertEqual(1, code)
        self.assertIn('ERROR: MS-ONE', out)
        self.assertEqual(2, self.run_main(register(), '--as-of', 'yesterday')[0])


if __name__ == '__main__':
    unittest.main()
