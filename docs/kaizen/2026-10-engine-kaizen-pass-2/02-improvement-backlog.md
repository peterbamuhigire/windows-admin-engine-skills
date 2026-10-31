# Improvement backlog and selection (31 October 2026)

Owner for every item: Peter Bamuhigire. Review point: 5 November 2026 (the date
the 29 October cycle set). Target for every plan is 95/100; the contribution
column is a conditional estimate that counts only if the named evidence exists.
Selection: 7 items, below the limit of ten. No canonical risk class, identity
scope or finance doctrine is changed; K1 encodes two rules the safety model
already states.

## Root causes (five whys, condensed)

**D5 to D7, fleet manifest fails open (critical).** Why did a `revoked`
manifest pass? The validator lists `revoked` as a legal status and never
branches on it. Why? The 6 September work added the status vocabulary to answer
a "missing authority" finding, and the test asserted only the vocabulary. Why
only the vocabulary? Every test mutates one field of the valid fixture and
asserts one error; none states the set of manifests that must be refused. Why
did nobody notice? The JSON schema is unused by any code, so no second view
disagreed with the validator. Root cause: proof (no paired refusal oracle) and
tooling (a schema that nothing consumes).

**D1 to D4, hygiene escapes.** Why do two plans name a missing skill? They were
written against a planned name. Why did no gate fail? Link checks cover
specialist skills and the hub, the machine-path scan covers two files, and no
check resolves skill identifiers in prose. Root cause: tooling (scanner
coverage is narrower than the claim "no machine paths, no broken links").

**D11, unenforced review interval.** Why can 36 rows lapse unnoticed? The
register states 90 days in prose-like policy data and no script computes it.
Root cause: process and tooling.

**D13, thin routing proof.** Why 3/19 coverage? The 29 October cycle added
fixtures only for skills it touched. Root cause: proof, by design of that cycle.

## Backlog

| ID / priority | Gap and defect | Exact change | Hypothesis | Acceptance evidence | Risk and rollback | Target contribution |
|---|---|---|---|---|---|---|
| K1 / P0 | Safety and integrity, fleet manifest. D5, D6, D7 | In `scripts/validate_fleet_manifest.py`: refuse `authority.status == "revoked"`; require `change_window` and each `maintenance_window` to be `<start>/<end>` ISO-8601 instants with a time zone and end after start; require each target window to lie inside the change window; refuse hostnames containing wildcard, list, range or whitespace characters; require owner different from approver for R4 and R5 targets unless status is `synthetic-test-only`. Unit tests for each refusal and one acceptance. | The nine probe mutations that pass today are refused and the valid fixture still passes. | Re-run of the probe table: every "refuse" row has at least one finding, the "accept" rows have none; `unittest` all pass; `scripts/validate_fleet_manifest.py` on the valid fixture exits 0. | Stricter validation only; a real manifest with free-text windows would now fail, and none exists (fixtures are synthetic, no fleet run has occurred). Revert the one commit. | Safety +4, production and handoff +2 |
| K2 / P1 | Production and handoff. D10 | Align `engine/schemas/fleet-target-manifest.schema.json` with the validator (authority object and status enum, non-empty text, non-empty targets, hostname pattern). Add paired refused manifests under `tests/fixtures/fleet-manifest/`. A test interprets the schema subset in use and requires that every refused manifest is rejected by both the schema and the validator, and that the valid fixture passes both. | A refusal that only one of the two artefacts catches fails the build. | `unittest` includes the parity test and passes; deleting `authority` from the schema makes it fail (checked once, then restored). | Schema and tests only; revert the commit. Time-based expiry is not expressible in the schema and stays validator-only, stated in the schema description. | Production +2, applied proof +2 |
| K3 / P1 | Hygiene and taxonomy. D1, D3, part of D4 | New `scripts/check_references.py`, called from `validate_engine.py`: resolve every local Markdown link in tracked Markdown outside fenced code, and every `windows-*` skill identifier in tracked prose, against the catalogue (explicit allow-list for platform and product tokens). Replace `windows-identity-ad` with `windows-active-directory-health` in the two plans. Replace the three links into a non-existent sibling path with plain text that says the log is held outside this repository. Unit tests with a temporary repository that fails on a broken link and on an unknown skill name. | The scanner finds the 5 current defects before the fix and 0 after; a new defect is caught. | Scanner run before the fix lists D1 and D3; after the fix `validate_engine.py` exits 0; tests prove detection. | Docs edits and a read-only scanner; revert the commit. False positives are handled by an allow-list with a stated reason per entry. | Hygiene +4, taxonomy +3 |
| K4 / P1 | Hygiene. D2, rest of D4 | New `scripts/check_portability.py`, called from `validate_engine.py`: fail on machine-specific absolute paths (a personal Windows profile, a development-drive checkout, a Unix home directory) in any tracked text file, with one named exemption for the test that deliberately holds such a literal. Rewrite the seven hits as engine or repository identifiers. Remove the two-file special case from `check_marketplace.py` only if the new scan subsumes it (keep it otherwise). Tests. | The 7 content hits go to 0; the exempt literal is the only match. | Scan output before and after; `validate_engine.py` and `unittest` pass. | Docs and skill-text edits, plus a scanner; revert the commit. The `windows-portability-doctrine` lines are provenance citations of a third-party checkout, reworded without losing the cited file and line. | Hygiene +3, safety +1 |
| K5 / P1 | Standards currency. D11 | New `scripts/check_source_register.py`: each URL row has an ISO `accessed` date (a `verified` date overrides it when present); fail when a row is older than `review_interval_days` at the as-of date (default today, `--as-of` for tests); report rows lapsing within 14 days as warnings; fail on an unknown `status` keyword. Register it in `.skills-engine/engine-manifest.yaml`, the operator manual and CI. Tests with a fixed date. | A lapsed or undated row can no longer pass a release check. | `unittest` pass; the script exits 0 today and, with `--as-of 2026-11-11`, exits 1 naming the 36 rows. | Adds a gate that goes red on a calendar date by design. Revert the commit, or refresh the rows. The 2026-11-10 lapse is stated in the report. | Currency +4 |
| K6 / P2 | Applied proof and routing. D13 | Add three positive and two owned-negative fixtures for each of eight specialists, in two commits: `windows-identity-lifecycle`, `windows-fleet-management`, `windows-backup-recovery`, `windows-patch-management`, then `windows-iis`, `windows-hyper-v`, `windows-network-admin`, `windows-remote-management`. If a fixture exposes a keyword gap, fix the catalogue keyword with the smallest exact change, not the fixture. | Coverage rises from 3/19 to 11/19 with first-rank precision unchanged at 100%. | `routing_smoke_test.py` exit 0 with the new totals; coverage script output. | Fixtures and catalogue keywords; revert each commit. A keyword change must keep every earlier fixture first-rank. | Taxonomy +3, applied proof +2 |
| K7 / P1 | Standards currency. D12 and the currentness items in the prompt | Verify against primary sources the Windows 11 and Windows Server servicing state, PowerShell support lifecycle, Intune, Entra and Azure Arc changes, Microsoft security baseline status, IIS and Hyper-V guidance. Record source, access date, support state and review date in a dated review document and in the register rows actually verified (`verified` date added; no blanket date change). Correct the `powershell-7` row of the platform matrix to its scoped evidence. Run `verify_source_urls.py`. | The register states which rows were verified on 2026-10-31 and which were not; the matrix stops contradicting the 29 October evidence. | The review document, the register diff showing only verified rows changed, `verify_source_urls.py` output, `check_source_register.py` exit 0. | Documentation and data only; revert the commit. Unverifiable items stay `NOT_ASSESSED`. | Currency +3 |

## Moved to the next cycle (not selected)

| Item | Reason |
|---|---|
| D8, `Invoke-WseServiceState` does not evaluate the window or authority | Needs a PowerShell edit; none can be verified on this host |
| D9, `wsa-dns-test` and `wsa-port-test` not manifest-bound | Same, and the right design (refuse, or label as unbounded read-only probes) needs a decision |
| D14, engine version `0.1.0` against `1.1.0` | Two version meanings are in use (module, catalogue, plugin); needs a decision before an edit |
| Canary field in the fleet manifest | Adds a field to a data contract the skills and plans rely on; Peter's decision |
| Windows integration, GPO/AD/SMB pilot, advisory applicability, timed restore | Need an isolated Windows lab; unchanged from 29 October |
| Domain-specific portable-contract migration; further mutating tools | Structural; unchanged from 29 October |
