"""Synthetic B26 controller, binding, and PowerShell semantics contracts."""

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "tests" / "fixtures" / "kaizen"


def load(name):
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


class KaizenContractTests(unittest.TestCase):
    def test_typed_controller_keeps_domain_and_presentation_separate(self):
        data = load("typed-controller-results.json")
        result = data["domain_result"]
        self.assertEqual(result["PSTypeName"], "WindowsSkills.OperationResult")
        self.assertEqual(result["Status"], data["invariants"]["direct_status"])
        self.assertEqual(data["presentation"]["source_operation_id"], result["OperationId"])
        self.assertTrue(data["invariants"]["formatter_is_not_domain_result"])
        self.assertFalse(data["invariants"]["read_only_changed"])
        self.assertEqual(data["failure_cases"][0]["expected"], "BLOCKED")
        self.assertEqual(data["failure_cases"][1]["expected"], "PARTIAL_RETAINED")

    def test_pipeline_binding_rejects_semantic_mismatch_and_nested_trace_mutation(self):
        data = load("pipeline-entity-mismatch.json")
        cases = {item["name"]: item for item in data["cases"]}
        self.assertEqual(cases["direct-valid"]["expected"], "ACCEPT")
        self.assertEqual(cases["process-id-mismatch"]["expected"], "REJECT_SEMANTIC_MISMATCH")
        self.assertFalse(cases["process-id-mismatch"]["mutation_called"])
        self.assertEqual(cases["empty-target"]["expected"], "REJECT_INVALID_TARGET")
        self.assertEqual(cases["trace-unapproved-nested-mutation"]["expected"], "REJECT_NO_EXECUTION")

    def test_powershell_semantics_preserve_array_and_partial_results(self):
        data = load("powershell-semantics.json")
        self.assertEqual(data["switch_array"]["expected_output"], ["A", "B"])
        self.assertFalse(data["membership"]["expected"])
        cancellation = data["cancellation"]
        self.assertEqual(cancellation["aggregate_status"], "PartiallySucceeded")
        self.assertFalse(cancellation["global_success"])
        self.assertEqual([row["status"] for row in cancellation["results"]], ["Succeeded", "NotProcessed", "NotProcessed"])


if __name__ == "__main__":
    unittest.main()
