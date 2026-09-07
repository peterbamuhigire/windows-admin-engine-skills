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
