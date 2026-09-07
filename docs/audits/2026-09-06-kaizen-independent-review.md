# Independent fleet-manifest review

Scope: current changes to `scripts/validate_fleet_manifest.py` and `tests/python/test_fleet_manifest.py`. Implementation was not edited. Local synthetic checks only; fleet authorisation, contact and readiness were not assessed. NO_TIME_SENSITIVE_CLAIMS.

## Verdict and findings

Remaining validation gaps; the focused tests pass, but do not cover the reproduced inputs below (synthesis).

- **Expiry normalisation can crash.** `datetime.fromisoformat` accepts the synthetic boundary timestamps below, but conversion to UTC raises `OverflowError`; the handler catches only `ValueError`. Both `validate_data` and the CLI entrypoint raise instead of returning the normal findings summary. This is a residual gap in the touched expiry block, not a newly introduced conversion behaviour. Catch overflow as an invalid expiry and add boundary tests through both entrypoints. [Implementation](../../scripts/validate_fleet_manifest.py#L48)
- **Hostname can become empty after the nonblank guard.** The synthetic hostname `...` passes the text check, then trailing-dot removal produces an empty canonical identity without a finding. Reject an empty canonical hostname and add a regression test. This finding concerns the validator's own identity normalisation, not a claim that it verifies DNS or actual devices. [Implementation](../../scripts/validate_fleet_manifest.py#L29)

## Dated disposition — 2026-09-07

The two residual validator defects identified here were repaired before resumed verification: extreme expiry values now have guarded handling and canonical hostname emptiness is rejected. The resumed Windows suite recorded 19 passing tests. This closes the bounded local repair item only; live fleet behaviour, authorisation, contact, recovery and broader release evidence remain **NOT ASSESSED**. Next review: 2026-09-13 ([log](../../skills-web-dev/docs/audits/2026-09-06-kaizen/resume-2026-09-07/windows-admin-engine-skills-tests.log)).

## Reproducible local evidence

Run from the repository root:

```powershell
python -X utf8 -m unittest discover -s tests/python -p test_fleet_manifest.py -v
```

Observed: focused suite completed successfully. Test coverage inspected in [test_fleet_manifest.py](../../tests/python/test_fleet_manifest.py).

The following in-memory probe was executed through Python; no manifest was written and no target was contacted:

```python
import copy, contextlib, io, json, sys
from unittest.mock import patch
sys.path.insert(0, 'tests/python')
from test_fleet_manifest import FleetManifestTests, MODULE
case = FleetManifestTests()
case.setUp()
for value in ['0001-01-01T00:00:00+01:00', '9999-12-31T23:59:59-01:00']:
    data = copy.deepcopy(case.data)
    data['expires_at'] = value
    try:
        print(MODULE.validate_data(data, case.now))
    except Exception as exc:
        print(type(exc).__name__, str(exc))
    with patch.object(MODULE.Path, 'read_text', return_value=json.dumps(data)):
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                MODULE.main(['synthetic-manifest.json'])
        except Exception as exc:
            print(type(exc).__name__, str(exc))
data = copy.deepcopy(case.data)
data['targets'][0]['hostname'] = '...'
print(MODULE.validate_data(data, case.now))
```

Observed execution evidence: each expiry produced `OverflowError` with message `date value out of range` through the function and CLI entrypoint; the hostname probe returned `[]`. These are local fixture outcomes only.

Review boundary: no operational PowerShell, live fleet checks, source-register edits, external research, or broader release certification. Existing unrelated changes were preserved.
