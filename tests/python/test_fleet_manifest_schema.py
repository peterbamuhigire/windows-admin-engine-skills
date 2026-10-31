"""Keep engine/schemas/fleet-target-manifest.schema.json and the validator in agreement.

No schema library is installed, so a small interpreter covers the keywords the
schema uses. An unsupported keyword fails the test instead of being skipped, so
a later schema edit cannot silently escape the parity check.
"""
import importlib.util
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('fleet_validator', ROOT / 'scripts/validate_fleet_manifest.py')
VALIDATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VALIDATOR)
SCHEMA = json.loads((ROOT / 'engine/schemas/fleet-target-manifest.schema.json').read_text(encoding='utf-8'))
FIXTURES = ROOT / 'tests/fixtures/fleet-manifest'

ANNOTATIONS = {'$schema', 'title', 'description'}
SUPPORTED = ANNOTATIONS | {'type', 'const', 'enum', 'required', 'properties', 'items',
                           'minItems', 'minLength', 'minimum', 'pattern'}

# Refusals a structural schema cannot express. Each needs a reason.
VALIDATOR_ONLY = {
    'refused-inverted-change-window.json': 'window end after start compares two values',
    'refused-target-window-outside-change-window.json': 'nesting compares two fields',
    'refused-expired.json': 'expiry needs the clock',
    'refused-duplicate-hostname.json': 'uniqueness across array items by field',
    'refused-exceeds-max-hosts.json': 'array length against another field',
    'refused-self-approved-r4.json': 'conditional on status, tier and two fields',
}


def is_type(value, name):
    if name == 'object':
        return isinstance(value, dict)
    if name == 'array':
        return isinstance(value, list)
    if name == 'string':
        return isinstance(value, str)
    if name == 'integer':
        return isinstance(value, int) and not isinstance(value, bool)
    if name == 'null':
        return value is None
    raise AssertionError(f'unsupported type {name}')


def schema_errors(schema, value, path='$'):
    unknown = set(schema) - SUPPORTED
    if unknown:
        raise AssertionError(f'unsupported schema keywords at {path}: {sorted(unknown)}')
    errors = []
    if 'type' in schema:
        names = schema['type'] if isinstance(schema['type'], list) else [schema['type']]
        if not any(is_type(value, name) for name in names):
            return [f'{path}: wrong type']
    if 'const' in schema and value != schema['const']:
        errors.append(f'{path}: const')
    if 'enum' in schema and value not in schema['enum']:
        errors.append(f'{path}: enum')
    if isinstance(value, str):
        if len(value) < schema.get('minLength', 0):
            errors.append(f'{path}: minLength')
        if 'pattern' in schema and not re.search(schema['pattern'], value):
            errors.append(f'{path}: pattern')
    if isinstance(value, int) and not isinstance(value, bool) and value < schema.get('minimum', value):
        errors.append(f'{path}: minimum')
    if isinstance(value, dict):
        errors += [f'{path}.{key}: required' for key in schema.get('required', []) if key not in value]
        for key, sub in schema.get('properties', {}).items():
            if key in value:
                errors += schema_errors(sub, value[key], f'{path}.{key}')
    if isinstance(value, list):
        if len(value) < schema.get('minItems', 0):
            errors.append(f'{path}: minItems')
        if 'items' in schema:
            for index, item in enumerate(value):
                errors += schema_errors(schema['items'], item, f'{path}[{index}]')
    return errors


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


class FleetManifestSchemaParityTests(unittest.TestCase):
    def test_valid_and_accepted_manifests_pass_schema_and_validator(self):
        paths = [ROOT / 'tests/fixtures/fleet-manifest.valid.json', *sorted(FIXTURES.glob('accepted-*.json'))]
        self.assertGreaterEqual(len(paths), 2)
        for path in paths:
            with self.subTest(path=path.name):
                data = load(path)
                self.assertEqual(schema_errors(SCHEMA, data), [])
                self.assertEqual(VALIDATOR.validate_data(data), [])

    def test_every_refused_manifest_is_refused_by_the_validator(self):
        paths = sorted(FIXTURES.glob('refused-*.json'))
        self.assertGreaterEqual(len(paths), 10)
        for path in paths:
            with self.subTest(path=path.name):
                self.assertTrue(VALIDATOR.validate_data(load(path)))

    def test_refusals_the_schema_can_express_are_refused_by_the_schema(self):
        for path in sorted(FIXTURES.glob('refused-*.json')):
            with self.subTest(path=path.name):
                rejected = bool(schema_errors(SCHEMA, load(path)))
                if path.name in VALIDATOR_ONLY:
                    self.assertFalse(rejected, f'{path.name} is now schema-detectable; remove it from VALIDATOR_ONLY')
                else:
                    self.assertTrue(rejected, f'{path.name} passes the schema but the validator refuses it')

    def test_validator_only_list_names_real_fixtures_with_reasons(self):
        names = {path.name for path in FIXTURES.glob('refused-*.json')}
        self.assertLessEqual(set(VALIDATOR_ONLY), names)
        self.assertTrue(all(VALIDATOR_ONLY.values()))

    def test_schema_requires_the_validator_field_sets(self):
        self.assertEqual(set(SCHEMA['required']), VALIDATOR.REQUIRED_ROOT | {'authority'})
        self.assertEqual(set(SCHEMA['properties']['authority']['required']), VALIDATOR.REQUIRED_AUTHORITY)
        self.assertEqual(set(SCHEMA['properties']['targets']['items']['required']), VALIDATOR.REQUIRED_TARGET)


if __name__ == '__main__':
    unittest.main()
