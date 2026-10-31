# Windows kaizen pass 2: final report (31 October 2026)

The fleet manifest validator no longer fails open, the registered validators now
see the content defects they missed, and the source-review interval is enforced.
This is a bounded improvement to the Python-checkable parts of the engine. **No
PowerShell behaviour was exercised in this pass** (no `pwsh` on the host), and
no Windows, domain, tenant or fleet was touched. Target **95 is not met**.

Scores are reviewer judgements (inference), equally weighted under the Standard.
The baseline is frozen at `8d6faea` (commit `1efef4c` records it); the
29 October final is shown for comparison. Three baseline scores were restated
below the 29 October final because this pass found evidence that score had not
counted (see `01-baseline-scorecard.md`).

| Dimension | 29 Oct final | Fresh baseline | After | Evidence and remaining deficiency |
|---|---:|---:|---:|---|
| Doctrine | 60 | 60 | 62 | The independent-approver rule for R4/R5 now has a check in the fleet path; manifest-only contact still has none for `wsa-dns-test` and `wsa-port-test` |
| Taxonomy and routing | 65 | 62 | 66 | No dangling skill names; 73/73 first rank, 23/23 owned negatives, coverage 11/19 with a ratchet; lexical oracles, 8 specialists uncovered |
| Skill depth | 60 | 60 | 60 | No new worked plan; 17 of 19 specialists still lack one |
| Applied proof | 55 | 55 | 58 | 72 Python tests (31 before), 16 refused and 2 accepted manifests with parity test and negative controls; no PowerShell or Windows proof ran |
| Standards currency | 50 | 48 | 54 | Nine rows verified with dated scoped review; interval now enforced; 35 rows lapse 2026-11-10; IIS on Server 2025 and Entra after June NOT_ASSESSED |
| Output readiness | 60 | 60 | 60 | Manifest cannot carry a canary; no real change packet |
| Accessibility and inclusion | 48 | 48 | 48 | No operator or accessibility study |
| Production and handoff | 58 | 58 | 60 | Fleet gate refuses revoked, unbounded and ambiguous manifests and the schema matches; no canary field, no restore proof |
| Hygiene | 65 | 58 | 65 | 12 content defects fixed; links, paths and identifiers scanned across all tracked files; plan files exempt from the identifier check; duplicated-heading check not built |
| Safety and integrity | 58 | 58 | 62 | Critical D5 fixed and verified; D8 and D9 (window and authority are text-only in the service function; probes not manifest-bound) are static findings still open |

Raw: baseline `567 / 10 = 56.7`; after `595 / 10 = 59.5`. Published scores:
`min(56.7, 65) = 56.7` and `min(59.5, 65) = 59.5`. The 29 October final was raw
57.9. No dimension is lower than its fresh baseline or than the 29 October final.
D5 was a release blocker for any use of the manifest as an execution gate; it is
closed for the Python validator. A failed recovery or a missing R4 approval still
blocks the operation it concerns, whatever this score.

## Kept changes

| Item | Commit | Evidence |
|---|---|---|
| K1 manifest validator refuses revoked, unbounded, ambiguous and self-approved (critical D5, D6, D7) | `cd81d03` | 9 probe mutations: 0 findings before, 1 each after; 5 new tests, written to fail first |
| K2 schema aligned, paired refused and accepted manifests, parity test (D10) | `83f3e03` | 16 refused and 1 extra accepted fixture; three negative controls fail as designed |
| K3 skill identifiers and links resolved across all Markdown (D1, D3) | `4ee2587` | 9 findings on the unfixed tree, 0 after; end-to-end negative control through `validate_engine.py` |
| K4 machine-path scan over all tracked files (D2) | `5336bef` | 12 findings on the `8d6faea` export, matching 3 + 2 + 7 by hand; 0 after |
| K5 source-register currency gate (D11) | `61b92a9` | 14 tests; exit 0 today, exit 1 as of 2026-11-11 |
| K6 routing fixtures for eight specialists and a coverage ratchet (D13) | `956a424`, `8acc8e5`, `9df4752` | 73/73 first rank; coverage 3/19 to 11/19 by two independent counts; floor control exits 1 |
| K7 verified currency, nine register rows, matrix correction (D12) | `8e7445f` | 46/46 URLs reachable; dated review document |
| Evidence folder and router update | final commit of the branch | this folder; `AGENTS.md` gates and links |

No experiment was reverted. Two prompts in K6 were rewritten before commit because
they passed only on a risk-class tie-break. Exact commands and outputs are in
`04-validation-record.md`.

## Branches

The repository started on `main` (HEAD `8d6faea`). Work was done on
`kaizen/2026-10-pass2`. At the end the checkout was returned to `main`. Nothing
was pushed, tagged or merged. The earlier local branch `kaizen/2026-10` and the
remote `origin/peterbamuhigire-patch-1` were not touched.

## Residual risk

- Every PowerShell file is unchanged and unexercised in this pass. The
  fixtures from 29 October ran under PowerShell 7.4.2, which ends support on
  2026-11-10.
- The validator checks manifest shape, windows, named hosts, approver separation
  and expiry. It does not verify that an approval is genuine or that any host is
  reachable or ready; its own output says so.
- `Invoke-WseServiceState` does not evaluate its window or authority (D8), and
  two probe commands are not manifest-bound (D9). Both are read from source only.
- The new currency gate turns red on 2026-11-11 unless rows are re-verified.
- Routing proof is lexical and written against this router; model routing is
  NOT_ASSESSED. Tier 3 behavioural runs were not made.
