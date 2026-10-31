# Windows kaizen pass 2: scope and evidence (31 October 2026)

This is a continuation of the 29 October cycle
([final report](../2026-10-engine-kaizen/05-final-report.md),
[next-cycle list](../2026-10-engine-kaizen/06-next-cycle.md)). Its primary
backlog input is that cycle's open items; each was re-confirmed before use.

## Step 0: preconditions

| Item | Observed |
|---|---|
| Starting branch and HEAD | `main`, `8d6faea3c5bbbb490c497d571b309b255a02daaa` |
| `git status --porcelain` at start | empty (0 lines); no foreign uncommitted files to preserve |
| Working branch | `kaizen/2026-10-pass2`, created from that HEAD with `git switch -c` |
| Other local branch | `kaizen/2026-10` (29 October work, already merged into `main`); not touched |
| Remote branch `origin/peterbamuhigire-patch-1` | not touched; see the reading in [06-next-cycle.md](06-next-cycle.md) |
| Push, tag, release, pull request | none made |

Read before acting: the Portfolio Kaizen Standard, the currentness gate, the
router (`AGENTS.md`), the hub skill, the engine kaizen skill, the 29 October
evidence folder, the September audits, `docs/safety-model.md`, the two worked
plans in `docs/operations/`, and the validators named below. The prompt's
`docs/engine-upgrade-july-2026/` folder and `docs/continuous-improvement/`
do not exist in this repository (confirmed with `ls`); that evidence is
NOT_ASSESSED.

## Runtime available

| Runtime | State |
|---|---|
| Python 3.14.8, `unittest` | available; all Python validators ran |
| `pwsh`, `powershell` | **absent** on this host (`bash: pwsh: command not found`, exit 127, for both `scripts/test-powershell.ps1` and `scripts/test-powershell-syntax.ps1`) |
| Windows, AD, SMB, IIS, Hyper-V, tenant | none available |

Consequence: **no PowerShell behaviour was exercised in this cycle.** Every
`wsa-` command run, both PowerShell validators and the three PowerShell fixture
scripts are NOT_ASSESSED here. This cycle therefore changed no `.ps1`, `.psm1`
or `.psd1` file, because a PowerShell edit could not be verified. A local image
`mcr.microsoft.com/powershell:latest` exists in the rootless Podman store; it
was not used, because the instruction for this run is to treat PowerShell as
NOT_ASSESSED. Whether to allow a throwaway container run is a decision for
Peter (see [06-next-cycle.md](06-next-cycle.md)).

## Step 1: observe

Evidence is held in [practitioner-before.md](practitioner-before.md): the full
router output for the three tasks.

### Task 1: Group Policy change, pilot OU then fleet

Request: "Plan a Group Policy change that sets a registry-based security
setting: first on a pilot OU of 5 machines, then across the whole fleet of 400
domain-joined machines."

Router: `windows-group-policy` (R4) first, `windows-security-analysis` second,
`windows-fleet-management` third. Group policy first is correct;
`windows-fleet-management` is the right owner for the fleet stage and ranked
below the read-only security skill on a token tie (5 against 5). Minor.

Judged against the five required properties, using
`skills/policy-security-and-compliance/windows-group-policy/SKILL.md` and
`docs/operations/group-policy-pilot.md`:

| Property | Specified? | Evidence |
|---|---|---|
| Risk class | yes, R4 | skill "Platform and privilege boundary"; plan line 5 |
| Preview | yes | plan step 3, `-WhatIf` and an independent approver, with the limit that preview does not prove client application |
| Canary | yes, as a pilot OU with an unchanged comparison client | plan step 4; concurrency one, retries zero |
| Verification | yes | plan step 5, RSoP on clients, comparison client unchanged |
| Rollback | yes | plan step 7, restore by backup ID, separate link reversal, no restore-all |

Gaps found: the plan sends the operator to `scripts/validate_fleet_manifest.py`
for the fleet stage (plan step 6), but that validator did not enforce a bounded
window, refused no wildcard host and accepted a revoked authority (defects D5
to D7 below). The plan's guard therefore passed manifests it should refuse.
The plan also names a skill that does not exist (D1).

### Task 2: file share unreachable after patching

Request: "Domain-joined machines cannot reach the file share after patching last
night, cause unknown."

Router: `windows-troubleshooting` first (reason `intent:diagnose-before-repair`),
then `windows-storage-files-services`, then `windows-patch-management`. Correct
and diagnosis-first. `docs/operations/file-share-after-patching.md` is ordered
and evidence-first: scope and comparison machine, then name resolution and TCP
445, then time, secure channel and Kerberos, then share and NTFS permissions,
then release-health correlation, then one canary repair, then verification and
single-change reversal. It states that patch timing is not causation and bans
disabling SMB signing or the firewall as a diagnostic shortcut.

Defect: step 3 routes a proved identity problem to `windows-identity-ad`,
which is not in the catalogue (D1). A fresh agent following the plan has no
such skill to load.

### Task 3: three `wsa-` commands in `-WhatIf`, out-of-scope target refused

NOT_ASSESSED: no `pwsh`. The router was run on the closest request
("Restart the Spooler service on host OUTSIDE-FIXTURE with -WhatIf preview");
it selected `windows-storage-files-services` and printed the R2 mutation
warning, which is the correct route and warning. The refusal itself lives in
`powershell/WindowsSkills.Engine/Private/Resolve-WseLocalTarget.ps1`, whose
non-local branch throws before any service lookup. That was read, not run. The
29 October cycle's fixture scripts cover it under PowerShell 7.4.2 in a Linux
container; they were not replayed here.

Static findings from reading the boundary code (not executed):

- `Invoke-WseServiceState.ps1:6-7,42` takes `-ChangeAuthority` and
  `-MaintenanceWindow` as non-empty text. Both appear only inside the
  `ShouldProcess` message. The window is never compared with the current time
  and the authority is not matched to any manifest, so "bounded window" and
  "explicit authority" are advisory in code (D8).
- `Invoke-WsaCommand.ps1:44-57` (`dns-test`, `port-test`) contact whatever
  host the operator types. `docs/safety-model.md:38` says only manifest targets
  may be contacted (D9). Both are read-only probes.

## Defects (critical, major, minor)

| ID | Severity | Defect | Location |
|---|---|---|---|
| D1 | Major | Two worked plans route to `windows-identity-ad`, a skill that does not exist. The catalogue owner for AD health is `windows-active-directory-health` | `docs/operations/group-policy-pilot.md:4`, `docs/operations/file-share-after-patching.md:21` |
| D2 | Major | Machine-specific or personal absolute paths (`C:\wamp64\www\...`, `C:\Users\Peter\Downloads\...`) in tracked content | `docs/control-plane-adoption.md:4`, `docs/plans/windows-engine/README.md:5-6`, `docs/research/book-driven-kaizen-operating-system.md:70`, `skills/meta/windows-portability-doctrine/SKILL.md:92,152,181` |
| D3 | Minor | Three relative links point into a sibling-checkout path that does not exist inside this repository | `docs/audits/2026-09-06-kaizen-independent-review.md:14`, `docs/audits/2026-09-06-kaizen.md:29` (two links) |
| D4 | Major | The scanners that should catch D1 to D3 cannot. The machine-binding scan reads only `AGENTS.md` and `README.md` (`scripts/check_marketplace.py:86`); `validate_engine.py` resolves links in specialist skills and the hub only; nothing resolves skill identifiers in prose | `scripts/check_marketplace.py:86`, `scripts/validate_engine.py` |
| D5 | **Critical** | A fleet manifest whose `authority.status` is `revoked` passes with zero findings and exit 0. The validator accepts `revoked` as a valid status and never refuses on it | `scripts/validate_fleet_manifest.py:25-26` |
| D6 | Major | Windows are unbounded text: `change_window` and `maintenance_window` of `whenever`, `x`, an inverted interval or a target window outside the change window all pass. Hostnames `*` and `A,B` pass, so "named targets" is not enforced | `scripts/validate_fleet_manifest.py:9-10,51` |
| D7 | Major | The safety model requires an independent approver for R4/R5 production work (`docs/safety-model.md:20-21`); the validator accepts owner equal to approver on an R4 target with status `approved` | `scripts/validate_fleet_manifest.py:19-26` |
| D8 | Major (static) | Service mutation takes authority and window as text only; neither is evaluated. Needs PowerShell to test | `powershell/WindowsSkills.Engine/Public/Invoke-WseServiceState.ps1:6-7,42` |
| D9 | Minor (static) | `wsa-dns-test` and `wsa-port-test` are not manifest-bound, against `docs/safety-model.md:38` | `commands/_lib/Invoke-WsaCommand.ps1:44-57` |
| D10 | Major | `engine/schemas/fleet-target-manifest.schema.json` omits `authority`, the status vocabulary, non-empty text and non-empty `targets`; nothing consumes it, so it is a documentation artefact that disagrees with the validator | `engine/schemas/fleet-target-manifest.schema.json` |
| D11 | Major | `engine/source-register.yaml` declares `review_interval_days: 90` but no validator reads any date. 36 URL rows dated 2026-08-12 reach 90 days on 2026-11-10 with nothing to flag them | `engine/source-register.yaml` (`policy`), `scripts/validate_engine.py` |
| D12 | Minor | `engine/platform-matrix.yaml` `powershell-7` row still says "pwsh absent on development host" although the 29 October cycle ran the syntax check and fixtures under PowerShell 7.4.2 | `engine/platform-matrix.yaml:12` |
| D13 | Minor | Routing fixtures cover 3 of 19 specialists to the three-positive, two-owned-negative threshold | `tests/fixtures/routing.json` |
| D14 | Minor | `windows-admin doctor` and the catalogue report `engine: 0.1.0`; the plugin and engine manifest say `1.1.0` | `python/windows_admin/cli.py:68`, `engine/catalog.yaml:3` |

D5 is the only critical defect. It is empirical, not inferred: the mutated
manifests and findings counts are in [04-validation-record.md](04-validation-record.md)
(before and after).

## Guidance missing, contradictory or ignored

- The Group Policy plan says a successful pilot "does not authorise an
  unbounded fleet operation" and tells the operator to run the manifest
  validator, but the validator accepted unbounded windows and wildcards. The
  guidance existed; the guard behind it did not.
- `docs/safety-model.md:20-21` (independent approver) and `:38` (only manifest
  targets) are stated rules with no check behind them in the fleet path.
- The prior cycle's 29 October report scores hygiene at 65 while its own
  validation record says wider link coverage was "not exhaustive". The scan
  run here finds D1 to D3, so that score is restated in the baseline.
- Canary: the fleet manifest has no field that represents a canary ring. The
  skill text and plans require one; the data contract cannot carry it. This is
  a design question, not a defect to patch silently (see
  [06-next-cycle.md](06-next-cycle.md)).

## Cross-engine references checked (read-only)

The engine names in the router resolve to real checkouts, and the files named
in `AGENTS.md` and `engine/source-register.yaml` exist: the development
engine's `docs/source-registers/skills-engine-currentness-2026-09.json` and
`docs/engine-control-plane.json`, the research engine's
`docs/continuous-improvement/kaizen-currentness-gate.md` and
`machine-errors-editorial-gate-2026-09-03.md`, and the coordination package's
`docs/operations/portfolio-craft-standard-2026-09-04.md`. The six commands the
development engine's control plane lists for this engine
(`wsa-route`, `wsa-inventory`, `wsa-health`, `wsa-security`,
`wsa-service-state`, `wsa-evidence-validate`) all exist in
`engine/command-catalog.json`. One naming drift: `engine/source-register.yaml:8`
and `docs/release/delivery-evidence-pack.md:12` say `digital-research-skills`,
while `AGENTS.md` says `digital-research-engine`. Dangling cross-engine
references: 0.
