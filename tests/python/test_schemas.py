from pathlib import Path
import sys
import unittest

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "python"))

from windows_admin.schemas import validate_operation


class SchemaTests(unittest.TestCase):
    def test_minimal_operation_contract(self):
        value = {
            "SchemaVersion":"1.0","OperationId":"operation-1","Command":"Test",
            "Target":{"Kind":"Local","Name":"HOST"},"IdentityContext":{},
            "Status":"NoChange","Changed":False,"RebootRequired":False,
            "DisconnectRisk":False,"StartedAt":"2026-08-12T00:00:00Z",
            "FinishedAt":"2026-08-12T00:00:01Z","Before":None,"After":None,
            "Verification":{},"RollbackArtifact":None,"EvidencePath":None,
            "Errors":[],"Warnings":[],
        }
        self.assertEqual(validate_operation(value), [])

    def test_invalid_status_and_target_fail(self):
        errors = validate_operation({"SchemaVersion":"1.0","Status":"Healthy"})
        self.assertGreaterEqual(len(errors), 2)


if __name__ == "__main__":
    unittest.main()
