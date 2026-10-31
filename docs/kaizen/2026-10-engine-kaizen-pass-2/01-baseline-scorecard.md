# Windows engine pass 2: frozen baseline (31 October 2026)

Frozen at `8d6faea3c5bbbb490c497d571b309b255a02daaa` before any change on
`kaizen/2026-10-pass2`. Scores are reviewer judgements (inference) from the
named evidence, equally weighted under the Standard. The published score is
`min(raw, 65)`. This baseline is a fresh measurement; the 29 October final is
shown beside it. Three dimensions are restated downwards from that final where
this pass found evidence the earlier score did not account for.

| Dimension | 29 Oct final | Fresh baseline | Evidence and one-line deficiency |
|---|---:|---:|---|
| Doctrine | 60 | 60 | R0 to R5 classes, `ShouldProcess` and authority separation are coherent (`AGENTS.md`, `docs/safety-model.md`). Two stated rules have no check behind them in the fleet path: independent approver (`:20-21`) and manifest-only contact (`:38`). |
| Taxonomy and routing | 65 | 62 | 34/34 first-rank, 7/7 owned negatives, but both worked plans send a fresh agent to `windows-identity-ad`, which is not in the catalogue (D1); only 3/19 specialists meet three positives and two owned negatives. |
| Skill depth | 60 | 60 | Two complete worked plans (Group Policy, post-patch incident); 17 of 19 specialists have no worked example. |
| Applied proof | 55 | 55 | 31 Python tests, nine service-state and three wrapper fixtures from 29 October; none of the PowerShell proof could run in this pass, and no Windows integration exists. |
| Standards currency | 50 | 48 | Scoped dated review exists, but 37 rows are `current-check-required` and no validator reads any date, so the 90-day interval is unenforced (D11); 36 rows lapse on 2026-11-10. |
| Output readiness | 60 | 60 | Typed service wrapper and two plans exist; fleet manifest output cannot express a canary and accepts unbounded windows (D6). |
| Accessibility and inclusion | 48 | 48 | Plain, readable text; no operator-usability or accessibility review exists. |
| Production and handoff | 58 | 58 | Failure exit and verified recovery exist for one service command; the fleet gate fails open on a revoked authority (D5). |
| Hygiene | 65 | 58 | Seven machine or personal paths, three broken links and two dangling skill names in tracked content, none caught by the registered validators (D1 to D4). |
| Safety and integrity | 58 | 58 | Refusal and failed-restore fixtures exist; the fleet manifest validator fails open on `revoked`, wildcard hosts and self-approved R4 (D5 to D7); authority and window are text-only in the service function (D8). |

**Raw fresh baseline:** (60 + 62 + 60 + 55 + 48 + 60 + 48 + 58 + 58 + 58) / 10 =
567 / 10 = **56.7**. **Published:** `min(56.7, 65) = 56.7`.
The 29 October final was raw 57.9, published 57.9. Target 95 is not met. D5 is
a safety blocker for any use of the fleet manifest as an execution gate,
whatever the score.

## Measured inputs

| Measure | Value | Command or source |
|---|---|---|
| `validate_engine.py` | exit 0; 19 specialists; 0 findings; package 291, checkout 508 files, limit 5000 | `python3 -X utf8 scripts/validate_engine.py` |
| `routing_smoke_test.py` | exit 0; 34 fixtures; 0 failures; precision@1 34/34; owned negatives 7/7 (lexical proxy, not model behaviour) | `python3 -X utf8 scripts/routing_smoke_test.py` |
| `source_ingestion_guardrail.py` | exit 0; 0 findings | same pattern |
| `validate_command_tree.py` | exit 0; 48 commands; 0 findings | same pattern |
| `validate_operator_manual.py` | exit 0; 48 commands, 17 scripts, 12 functions; 0 findings | same pattern |
| `check_marketplace.py` | exit 0; skills 20, package 291, checkout 508; no findings | same pattern |
| Python unit tests | exit 0; 31 tests | `PYTHONPATH=python python3 -X utf8 -m unittest discover -s tests/python -v` |
| `tests/test_approval_adapter.py` | exit 0; 1 test | `python3 -X utf8 -m unittest tests/test_approval_adapter.py` |
| `verify_source_urls.py` | exit 0; 38/38 reachable; 0 failures (liveness only, not claim support) | `python3 -X utf8 scripts/verify_source_urls.py --out <scratch>` |
| `scripts/test-powershell.ps1` | **NOT_ASSESSED**: `bash: pwsh: command not found`, exit 127 | `pwsh -NoProfile -File scripts/test-powershell.ps1` |
| `scripts/test-powershell-syntax.ps1` | **NOT_ASSESSED**: `bash: pwsh: command not found`, exit 127 | `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` |
| Fleet fixture validator | exit 0 on the one valid fixture | `python3 -X utf8 scripts/validate_fleet_manifest.py tests/fixtures/fleet-manifest.valid.json` |
| Routing precision@1 | 34/34 | as above |
| Owned negatives | 7 fixtures, all pass | as above |
| Fixture coverage (3 positives and 2 owned negatives, counting a negative against the skill named in `forbidden_primary`) | 3/19: `windows-group-policy`, `windows-storage-files-services`, `windows-troubleshooting` | measured with a script over `tests/fixtures/routing.json` |
| Worked-example depth | 2 plans linked from skills (Group Policy, post-patch incident); 2/20 skills | `grep` for links to `docs/operations/*` from `skills/` |
| Broken local Markdown links, all 77 tracked-file links outside fenced code | 3 broken (D3) | link resolver over `git ls-files` |
| Machine-specific absolute paths in tracked text | 8 matches: 7 in content (D2) plus 1 deliberate literal in `tests/python/test_marketplace.py:105` that tests the detector | path scan over `git ls-files` |
| Skill identifiers in prose that do not resolve to the catalogue | 2 (D1): `windows-identity-ad` | identifier scan over `git ls-files` |
| Dangling cross-engine references | 0 | read-only existence checks, see [00-scope-and-evidence.md](00-scope-and-evidence.md) |
| Expired source records (90-day interval, as of 2026-10-31) | 0 expired. 36 URL rows accessed 2026-08-12 lapse on 2026-11-10; 2 rows accessed 2026-09-24 lapse on 2026-12-23. The 10 rows with no `accessed` date are books (no URL); the 29 October count of "10 lack accessed" referred to them | arithmetic over `engine/source-register.yaml` |
| Source rows by status | 37 `current-check-required`, 3 `historical-only`, 2 `verify-every-command`, 2 `currentness-check-required`, 1 each of `do-not-execute-directly`, `stable-concepts-current-apis-verified`, `partial-edition`, `verify-tool-version` | same |

## Fleet manifest probe (D5 to D7), before any change

The valid fixture `tests/fixtures/fleet-manifest.valid.json`, with one field
changed at a time, validated with `validate_data(data, 2026-10-31)`:

| Mutation | Findings before | Should be |
|---|---:|---|
| none | 0 | accept |
| `authority.change_window = "whenever"` | 0 | refuse |
| change window end before start | 0 | refuse |
| target `maintenance_window` outside the change window | 0 | refuse |
| target `maintenance_window = "x"` | 0 | refuse |
| target `hostname = "*"` | 0 | refuse |
| target `hostname = "A,B"` | 0 | refuse |
| `authority.status = "revoked"` | **0** | refuse |
| R4 target, status `approved`, owner equal to approver | 0 | refuse |
| extra unknown top-level field | 0 | accept (kept; see backlog K1) |
