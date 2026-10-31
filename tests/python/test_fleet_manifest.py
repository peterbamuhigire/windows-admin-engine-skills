import copy
import importlib.util
import json
from datetime import datetime, timezone
from pathlib import Path
import unittest
from unittest.mock import patch
import contextlib
import io

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('fleet_validator', ROOT / 'scripts/validate_fleet_manifest.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class FleetManifestTests(unittest.TestCase):
    def setUp(self):
        self.data = json.loads((ROOT / 'tests/fixtures/fleet-manifest.valid.json').read_text(encoding='utf-8'))
        self.now = datetime(2026, 9, 6, tzinfo=timezone.utc)

    def test_valid_fixture(self):
        self.assertEqual(MODULE.validate_data(self.data, self.now), [])

    def test_authority_manifest_is_required_and_bounded(self):
        data = copy.deepcopy(self.data)
        data["authority"]["status"] = ""
        self.assertIn("authority requires non-empty text: ['status']", MODULE.validate_data(data, self.now))
        data["authority"]["status"] = "unverified"
        self.assertIn("authority.status must be synthetic-test-only, approved, or revoked", MODULE.validate_data(data, self.now))

    def test_malformed_roots_and_fields(self):
        for root in (None, [], True):
            self.assertTrue(MODULE.validate_data(root, self.now))
        for field, values in {'max_hosts':[True, 1.5, '2', 0, -1, None],
                              'approved_by':[' ', None, True],
                              'targets':[[], None, {}]}.items():
            for value in values:
                with self.subTest(field=field, value=value):
                    data = copy.deepcopy(self.data)
                    data[field] = value
                    self.assertTrue(MODULE.validate_data(data, self.now))

    def test_either_duplicate_identity_blocks(self):
        for field in ('hostname', 'device_id'):
            data = copy.deepcopy(self.data)
            second = copy.deepcopy(data['targets'][0])
            second['hostname'] = 'OTHER-HOST'
            second['device_id'] = 'other-device'
            second[field] = data['targets'][0][field].swapcase()
            data['targets'].append(second)
            self.assertTrue(any('duplicate' in e for e in MODULE.validate_data(data, self.now)))

    def test_exact_expiry_is_expired(self):
        self.data['expires_at'] = self.now.isoformat()
        self.assertIn('manifest is expired', MODULE.validate_data(self.data, self.now))

    def test_unrepresentable_utc_expiry_fails_function_and_cli(self):
        for expiry in ('0001-01-01T00:00:00+01:00', '9999-12-31T23:59:59-01:00'):
            self.data['expires_at'] = expiry
            self.assertTrue(any('representable' in e for e in MODULE.validate_data(self.data, self.now)))
            with patch.object(MODULE.Path, 'read_text', return_value=json.dumps(self.data)):
                with contextlib.redirect_stdout(io.StringIO()) as output:
                    self.assertEqual(MODULE.main(['synthetic.json']), 1)
                self.assertIn('contact_attempted=false', output.getvalue())

    def test_empty_canonical_hostname_is_rejected(self):
        self.data['targets'][0]['hostname'] = '...'
        self.assertTrue(any('canonical hostname' in e for e in MODULE.validate_data(self.data, self.now)))

    def test_unknown_risk_and_blank_target_fields(self):
        for field in MODULE.REQUIRED_TARGET:
            data = copy.deepcopy(self.data)
            data['targets'][0][field] = ' '
            self.assertTrue(MODULE.validate_data(data, self.now))
        self.data['targets'][0]['risk_tier'] = 'R6'
        self.assertTrue(MODULE.validate_data(self.data, self.now))

    def refused(self, mutate):
        data = copy.deepcopy(self.data)
        mutate(data)
        return MODULE.validate_data(data, self.now)

    def test_revoked_authority_is_refused_by_function_and_cli(self):
        self.data['authority']['status'] = 'revoked'
        self.assertIn('authority is revoked', MODULE.validate_data(self.data, self.now))
        with patch.object(MODULE.Path, 'read_text', return_value=json.dumps(self.data)):
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(MODULE.main(['synthetic.json']), 1)

    def test_windows_must_be_bounded_intervals(self):
        bad = ('whenever', 'x', '', '2098-12-31T20:00:00Z',
               '2098-12-31T21:00:00Z/2098-12-31T20:00:00Z',
               '2098-12-31T20:00:00Z/2098-12-31T20:00:00Z',
               '2098-12-31T20:00:00/2098-12-31T21:00:00',
               '2098-12-31T20:00:00Z/open', 'a/b/c')
        for value in bad:
            with self.subTest(value=value):
                self.assertTrue(any('change_window' in e for e in self.refused(
                    lambda d: d['authority'].__setitem__('change_window', value))))
                self.assertTrue(any('maintenance_window' in e for e in self.refused(
                    lambda d: d['targets'][0].__setitem__('maintenance_window', value))))

    def test_target_window_must_lie_inside_change_window(self):
        outside = ('2099-06-01T00:00:00Z/2099-06-01T01:00:00Z',
                   '2098-12-31T19:59:00Z/2098-12-31T21:00:00Z',
                   '2098-12-31T20:00:00Z/2098-12-31T21:00:01Z')
        for value in outside:
            with self.subTest(value=value):
                self.assertTrue(any('outside authority.change_window' in e for e in self.refused(
                    lambda d: d['targets'][0].__setitem__('maintenance_window', value))))
        inside = ('2098-12-31T20:15:00Z/2098-12-31T20:45:00Z',
                  '2098-12-31T22:00:00+02:00/2098-12-31T23:00:00+02:00')
        for value in inside:
            with self.subTest(value=value):
                self.assertEqual(self.refused(
                    lambda d: d['targets'][0].__setitem__('maintenance_window', value)), [])

    def test_hostname_must_name_exactly_one_host(self):
        for value in ('*', 'host-*', 'A,B', 'A;B', 'a b', '10.0.0.0/8', 'srv[01-05]', 'a\\b', 'srv?'):
            with self.subTest(value=value):
                self.assertTrue(any('hostname must name exactly one host' in e for e in self.refused(
                    lambda d: d['targets'][0].__setitem__('hostname', value))))
        for value in ('LAB-CLIENT-01', 'srv01.corp.example', 'srv_01', '192.0.2.10'):
            with self.subTest(value=value):
                self.assertEqual(self.refused(
                    lambda d: d['targets'][0].__setitem__('hostname', value)), [])

    def test_r4_and_r5_production_need_an_independent_approver(self):
        def production(tier, owner, approver, status='approved'):
            def mutate(d):
                d['authority'].update(owner=owner, approver=approver, status=status)
                d['targets'][0]['risk_tier'] = tier
            return mutate
        for tier in ('R4', 'R5'):
            with self.subTest(tier=tier):
                self.assertTrue(any('independent approver' in e for e in self.refused(
                    production(tier, 'Ops-Lead', ' ops-lead '))))
                self.assertEqual(self.refused(production(tier, 'ops-lead', 'security-reviewer')), [])
        self.assertEqual(self.refused(production('R2', 'ops-lead', 'ops-lead')), [])
        self.assertEqual(self.refused(production('R4', 'lab-owner', 'lab-owner', 'synthetic-test-only')), [])
