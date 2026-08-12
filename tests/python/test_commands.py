from pathlib import Path
import json
import unittest

REPO=Path(__file__).resolve().parents[2]

class CommandTreeTests(unittest.TestCase):
    def test_every_direct_powershell_command_has_cmd_launcher(self):
        scripts=list((REPO/'commands').glob('[0-9][0-9]-*/*/wsa-*.ps1'))
        self.assertGreaterEqual(len(scripts),40)
        for script in scripts:
            self.assertTrue(script.with_suffix('.cmd').is_file(),script)
    def test_generated_catalog_has_unique_commands(self):
        data=json.loads((REPO/'engine/command-catalog.json').read_text(encoding='utf-8'))
        names=[item['command'] for item in data['commands']]
        self.assertEqual(len(names),len(set(names)))
        self.assertEqual(sum(1 for item in data['commands'] if item['mutation']),1)

if __name__=='__main__':unittest.main()
