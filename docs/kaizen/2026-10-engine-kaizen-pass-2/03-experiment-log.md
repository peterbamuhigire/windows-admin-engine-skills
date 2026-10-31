# Experiment log (31 October 2026)

One change at a time, highest priority first. Each kept change has its own
commit. No experiment was reverted. Every item re-ran all registered Python
gates after the edit; the full results are in `04-validation-record.md`.
PowerShell was unavailable throughout, so no `.ps1`, `.psm1` or `.psd1` file was
edited.

## K1: fleet manifest validator (critical defect D5, with D6 and D7)

Before: nine probe mutations of the valid fixture all returned zero findings,
including `authority.status = "revoked"`.

Change (`cd81d03`): `scripts/validate_fleet_manifest.py` now refuses a revoked
authority; requires `change_window` and every `maintenance_window` to be a
`<start>/<end>` pair of zoned ISO-8601 instants with the end after the start;
requires each target window inside the change window; refuses hostnames with
wildcard, list, range, path or whitespace characters; and requires owner and
approver to differ for R4 and R5 targets when the status is `approved`
(`synthetic-test-only` is exempt, matching `docs/safety-model.md:20-21`). Tests
were written first and failed (23 sub-test failures) before the change.

After: the same nine mutations each return one finding; the valid fixture and a
manifest with an extra field both still pass. The `wsa-fleet-validate` and
script rows of the operator manual now list the checks.

Not done: a canary field. The skill and plans require a canary, the manifest
cannot represent one, and adding a field changes a data contract. Held for
Peter's decision (`06-next-cycle.md`).

## K2: schema alignment and paired fixtures (D10)

Change (`83f3e03`): `engine/schemas/fleet-target-manifest.schema.json` now
carries the authority object, the status enumeration (without `revoked`, which
both artefacts refuse), non-empty text, non-empty targets, and hostname and
window patterns. Sixteen refused manifests and one extra accepted manifest sit
in `tests/fixtures/fleet-manifest/`. `tests/python/test_fleet_manifest_schema.py`
interprets the schema subset with no library, fails on any keyword it does not
support, requires every refused manifest to be refused by the validator, and
requires every refusal the schema can express to be refused by the schema too.
Six refusals the schema cannot express (clock, comparison of two values, array
uniqueness, array length against a field, conditional approver rule) are named
with reasons in the test.

Negative controls, run and then restored from a byte-identical copy:
dropping `authority` from `required` fails two tests; re-adding `revoked` to the
enumeration fails one; adding `uniqueItems` fails on the unsupported keyword.

## K3: reference resolver (D1, D3, part of D4)

Change (`4ee2587`): `scripts/check_content_hygiene.py`, called from
`validate_engine.py`, resolves every local Markdown link outside fenced and
inline code, and every `windows-*` identifier in Markdown against the catalogue,
the hub and a named list of non-skill identifiers. Run on the unfixed tree it
reported nine findings (the five known defects, plus four links in this
folder's own files to files not yet written, which proved it also catches those).
Fixed: `windows-identity-ad` became `windows-active-directory-health` in the
two plans, with account or trust repair routed to `windows-identity-lifecycle`;
the three audit links became plain text naming the log's home in the
development engine. Ten tests with temporary repositories.

Negative control through the real entry point: appending a broken link and an
unknown skill identifier to `docs/threat-model.md` made `validate_engine.py`
exit 1 with both findings; the file was restored from a byte-identical copy.

## K4: portability scan (D2, rest of D4)

Change (`5336bef`): the same module now scans every tracked text file for a
personal Windows profile, a development-drive checkout or a Unix home path.
`docs/plans/` is covered; two test files that hold such paths on purpose are
named exemptions. Run against an export of `8d6faea` it reports 12 findings: the
seven paths plus the five reference defects, matching the hand counts (3 links,
2 identifiers, 7 paths). The seven paths were rewritten as engine identifiers;
the citations in `windows-portability-doctrine` keep the cited file and the line
numbers.

One design correction during the work: the first pattern included a session
scratch directory, which is specific to one tool. It was removed rather than
exempting the script that held it. The pattern in `check_marketplace.py`
(`AGENTS.md` and `README.md` only) was left in place; it is now a subset.

Wording-only edit: `00-scope-and-evidence.md` and `02-improvement-backlog.md`
said the offending paths literally, which the new scan flags. They now describe
the paths. No measurement or score changed.

## K5: source-register gate (D11)

Change (`61b92a9`, extended in `8e7445f`): `scripts/check_source_register.py`
fails on a URL row without a valid `accessed` date, a row older than
`policy.review_interval_days` (a `verified` date overrides), a passed
`*_review_date` policy entry or row-level `review_by`, an unknown status, and a
malformed register; it warns 14 days ahead. Registered in the engine manifest,
CI and the operator manual. Fourteen tests with fixed dates, including both
sides of the 90-day boundary.

Result today: exit 0, 35 warnings. As of 2026-11-11 the script exits 1 with 39
findings: 35 expired rows, the 2026-11-05 scoped review date, and three new rows
whose `review_by` is 2026-11-10. This is intended: a gate that cannot turn red on a date does not enforce
the interval. It is also a consequence Peter should know about before 2026-11-11.

## K6: routing fixtures (D13)

Changes (`956a424`, `8acc8e5`, `9df4752`): three positives and two owned
negatives for each of eight specialists (identity lifecycle, fleet management,
backup and recovery, patch management, IIS, Hyper-V, network administration,
remote management): 39 fixtures, 73 in total. A check on the first batch found
two negatives that passed only on the risk-class tie-break; their prompts were
rewritten to win by a margin. Every new negative now has the forbidden skill
scoring above zero (non-vacuous) and a margin of at least 1; the single margin
of 1 is the diagnosis-first rule's designed `+1`. No catalogue keyword or ranking
rule needed to change. `routing_smoke_test.py` now prints coverage and fails
below a floor of 11. Negative control: removing two IIS fixtures drops coverage
to 10/19 and the script exits 1; restored.

Limits: the fixtures are lexical oracles written against this router, so they
guard against regression, not against a model reading a prompt differently.

## K7: currency (D12)

Change (`8e7445f`): nine register rows verified on 2026-10-31 from Microsoft
Learn pages (Windows 11 and Windows Server release information, PowerShell
support lifecycle, IIS lifecycle, Hyper-V overview, Azure Arc agent release
notes, Intune and Entra release notes, Security Compliance Toolkit). Each carries
`verified`, `as_of`, `freshness`, `review_by`, `support_state` and `limitation`.
No other row's date was touched. `docs/research/currentness-2026-10-31.md`
records the claims, the Windows 11 and Azure Arc rows it supersedes, and the
gaps: IIS on Server 2025 and Entra changes after June 2026 stay NOT_ASSESSED,
and advisory applicability and model currentness were not re-assessed. The
`powershell-7` row of `engine/platform-matrix.yaml` now matches the 29 October
container evidence (PARTIAL, a Linux container, an unsupported patch level).

## Not done from the prompt

- A duplicated-contract-heading check. The Standard's hand-checked list
  mentions it; this engine's skills keep their headings in the validator's
  required list, and no duplicated-heading defect was observed, so no scanner
  was built without a defect to test it against.
- Any PowerShell, Pester, container or live-Windows check.
