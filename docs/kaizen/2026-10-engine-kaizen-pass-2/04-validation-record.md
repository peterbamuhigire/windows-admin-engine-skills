# Validation record (31 October 2026)

Run from the repository root on Linux with Python 3.14.8 and the standard
library's `unittest` (no `pytest`). `PYTHONDONTWRITEBYTECODE=1` was set. The
results below are from the last run after the final repository edit, at the
commit before the evidence-folder commit. No package was installed. No host,
domain, tenant or fleet was contacted. The only network use was read-only HTTP:
`verify_source_urls.py` and Microsoft Learn page fetches.

## Registered and added gates

| Exact command | Exit | Result |
|---|---:|---|
| `python3 -X utf8 scripts/validate_engine.py` | 0 | 19 specialists, 0 findings; package 322, checkout 683 files, limit 5000; includes the new content-hygiene check |
| `python3 -X utf8 scripts/routing_smoke_test.py` | 0 | 73 fixtures, 0 failures; precision@1 73/73; owned negatives 23/23; fixture coverage 11/19 (floor 11); lexical proxy |
| `python3 -X utf8 scripts/source_ingestion_guardrail.py` | 0 | 0 findings |
| `python3 -X utf8 scripts/validate_command_tree.py` | 0 | 48 commands, 0 findings |
| `python3 -X utf8 scripts/validate_operator_manual.py` | 0 | 48 commands, 19 scripts, 12 functions, 0 findings |
| `python3 -X utf8 scripts/check_marketplace.py` | 0 | skills 20, package 322, checkout 683, no findings |
| `python3 -X utf8 scripts/check_content_hygiene.py` (new) | 0 | 0 findings |
| `python3 -X utf8 scripts/check_source_register.py` (new) | 0 | as of 2026-10-31: 56 rows, 46 URL rows, 0 expired, 35 warnings (interval ends 2026-11-10) |
| `python3 -X utf8 scripts/validate_fleet_manifest.py tests/fixtures/fleet-manifest.valid.json` | 0 | 1 target, 0 findings, `contact_attempted=false`, approval authenticity and fleet readiness NOT_ASSESSED |
| `PYTHONPATH=python python3 -X utf8 -m unittest discover -s tests/python` | 0 | 72 tests pass (31 at the baseline) |
| `python3 -X utf8 -m unittest tests/test_approval_adapter.py` | 0 | 1 test passes |
| `python3 -X utf8 scripts/verify_source_urls.py --out <scratch file>` | 0 | baseline 38/38 reachable; after K7, 46/46 reachable, 0 failures (liveness only, not claim support) |

## NOT_ASSESSED

| Check | Why |
|---|---|
| `scripts/test-powershell.ps1`, `scripts/test-powershell-syntax.ps1`, `scripts/test-service-state-fixture.ps1`, `scripts/test-service-wrapper-fixture.ps1` | `pwsh -NoProfile -File <script>` returns `bash: pwsh: command not found`, exit 127, for each. Windows PowerShell is absent too. |
| Every `wsa-` command, in `-WhatIf` or otherwise | Same cause. Task 3 of the observation was therefore a route check and a source read only. |
| The module's out-of-scope target refusal | `Resolve-WseLocalTarget.ps1` was read, not run |
| Pester suites, CI `windows-latest` steps | No PowerShell or Windows runner |
| Windows, AD, SMB, Group Policy, IIS, Hyper-V, Intune, Entra or Arc behaviour | No lab, domain or tenant |
| Advisory applicability for any build | No named build or KB inventory; the dynamic advisory guide was not re-attempted |
| Model currentness | Claude run; no model-policy change proposed or made; no catalogue read |
| Tier 3 behavioural runs and paid model calls | Not authorised |
| Model routing quality | Only the lexical router was exercised |

Because PowerShell could not run, **PowerShell behaviour was not exercised in
this pass**, and no PowerShell file was changed.

## Before and after measures

| Measure | Baseline (`8d6faea`) | After |
|---|---|---|
| Python unit tests | 31 | 72 |
| Routing fixtures, precision@1 | 34/34 | 73/73 |
| Owned negatives | 7/7 | 23/23 |
| Specialists with three positives and two owned negatives (counted a second way, directly from `routing.json` and `catalog.yaml`, independent of `routing_smoke_test.py`) | 3/19 | 11/19 |
| Broken local Markdown links across tracked Markdown (independent scan) | 3 of 77 | 0 of 80 |
| Machine-specific paths in content (independent scan; the two exempt test files excluded) | 7 | 0 |
| Skill identifiers that do not resolve | 2 | 0 |
| Content defects found by the new check on the baseline export | 12 | 0 on the tree |
| Expired source rows at 2026-10-31 (independent arithmetic) | 0 | 0 (35 lapse on 2026-11-10) |
| Source rows | 48 | 56 (8 added, `MS-SCT` re-verified) |
| Fleet manifest probe, findings per mutation | see below | see below |

Independent scan notes: the link and path scans after the change read only
tracked files; the first link scan reported one link broken between the
`AGENTS.md` edit and the writing of the final report, which resolved once that
file existed. The path scan lists five matches, all in the two named exempt test
files that hold such paths on purpose.

### Fleet manifest probe

The valid fixture with one field changed, `validate_data(data, 2026-10-31)`,
findings returned.

| Mutation | Before | After |
|---|---:|---:|
| none | 0 | 0 |
| `change_window = "whenever"` | 0 | 1 |
| change window end before start | 0 | 1 |
| target window outside the change window | 0 | 1 |
| `maintenance_window = "x"` | 0 | 1 |
| `hostname = "*"` | 0 | 1 |
| `hostname = "A,B"` | 0 | 1 |
| `authority.status = "revoked"` | 0 | 1 |
| R4 target, approved, owner equals approver | 0 | 1 |
| extra unknown top-level field | 0 | 0 (kept accepted by design) |

## Negative controls (checks proved able to fail)

| Control | Result |
|---|---|
| Drop `authority` from the schema's `required` list | parity test fails on two assertions; schema restored byte-identical |
| Re-add `revoked` to the schema's status enumeration | parity test fails; restored |
| Add an unsupported `uniqueItems` keyword to the schema | parity test fails naming the keyword; restored |
| Append a broken link and `windows-identity-ad` to `docs/threat-model.md`, run `validate_engine.py` | exit 1, two findings; file restored byte-identical |
| Remove two IIS routing fixtures, run `routing_smoke_test.py` | exit 1, coverage 10/19 below floor 11; restored |
| `check_source_register.py --as-of 2026-11-11` | exit 1, 39 findings (35 expired rows, the 2026-11-05 scoped review date, three `review_by` dates) |
| K1 tests before the code change | 23 sub-test failures; 0 after |
| New content check run on an export of `8d6faea` | 12 findings, matching the hand counts |

## Currency evidence (K7)

Pages were read on 2026-10-31 and treated as data. Support states and limits
are in `docs/research/currentness-2026-10-31.md` and the register rows
`MS-PS-LIFECYCLE`, `MS-WIN11-RELEASE`, `MS-WINSERVER-RELEASE`,
`MS-IIS-LIFECYCLE`, `MS-HYPERV-OVERVIEW`, `MS-ARC-AGENT-RELEASE`,
`MS-INTUNE-WHATS-NEW`, `MS-ENTRA-WHATS-NEW` and `MS-SCT`. Two of them are
`partial` (IIS, with no Server 2022 or 2025 row; Entra, whose newest section is
June 2026) and the Intune page was read only to its first 100,000 characters.

## Host-safety notes

- All edits are inside the repository and the session scratch directory. No
  `sudo`, no service, package, firewall or cron change.
- One shell command that included a recursive forced delete of a scratch
  directory was blocked by the destructive-command hook. It was not retried or
  worked around. The whole command was refused before it ran, so nothing in it
  executed; its edits were reapplied separately and the measurement ran in a new
  scratch directory that was not deleted afterwards.
- The local PowerShell container image was not run (see `06-next-cycle.md`).
- `git add` named explicit paths for every commit; no `git add -A`, `.` or
  `commit -a`. No push, tag, release, pull request, reset, clean or branch
  deletion.
