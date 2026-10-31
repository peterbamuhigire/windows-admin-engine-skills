# Next cycle, open findings and handoffs (31 October 2026)

Owner: Peter Bamuhigire. Re-audit date: **5 November 2026**, and in any case
before 2026-11-10, when 35 source rows, PowerShell 7.4 and 7.5 support and
Windows 11 23H2 Enterprise servicing all reach their dates. No Windows fleet
mutation should precede that re-audit.

## Decisions needed from Peter

1. **Allow a throwaway PowerShell container.** A local image
   `mcr.microsoft.com/powershell:latest` already exists in the rootless Podman
   store, but this pass treated PowerShell as NOT_ASSESSED as instructed. Running
   it read-only with networking disabled, as the 29 October cycle did, would let
   the syntax check and the three fixture scripts run again. Pulling a PowerShell
   7.6 LTS image would also replace the 7.4.2 runtime, which loses support on
   2026-11-10.
2. **How the fleet manifest represents a canary.** `windows-fleet-management`
   requires a canary, concurrency and a failure threshold, and no manifest field
   can carry them. Options: a `ring` field per target plus a `canary` object at
   the root, or a separate rollout manifest. Either changes a data contract.
3. **Whether `check_source_register.py` stays in CI.** It exits 0 today with 35
   warnings and exits 1 from 2026-11-11 unless the rows are re-verified. That is
   the intended behaviour; it is also a red build on a date.

## Open findings

| Priority | Finding | Next bounded experiment and acceptance |
|---|---|---|
| P1 | `Invoke-WseServiceState` takes `-ChangeAuthority` and `-MaintenanceWindow` as text and only prints them in the `ShouldProcess` message (`powershell/WindowsSkills.Engine/Public/Invoke-WseServiceState.ps1:6-7,42`). Static finding; not run | With PowerShell available: add a fixture where the window has passed or the authority is blank-equivalent and require a refusal before any service lookup, then implement it against the fixture. Acceptance: the fixture fails first and passes after, and the existing nine state assertions still pass |
| P1 | No Windows integration for service state, GPO, AD or SMB; no fleet window or canary run; no timed restore (carried from 29 October) | One approved isolated Windows VM and one disposable service, then one isolated domain pilot with a recorded backup ID, as listed in the 29 October next-cycle file |
| P1 | 35 source rows reach 90 days on 2026-11-10 | Re-verify the rows that matter to shipped guidance first (`MS-GROUP-POLICY`, `MS-SMB`, `MS-WINDOWS-UPDATE`, `MS-AD-RECOVERY`, `MS-WINDOWS-BACKUP`); set `verified` only on rows actually read. Acceptance: `check_source_register.py` exits 0 on the chosen date |
| P1 | Advisory applicability for a named estate is still unknown (carried) | Inventory named builds and KBs and correlate official advisories before any release statement |
| P2 | `wsa-dns-test` and `wsa-port-test` accept any host, against `docs/safety-model.md:38` (`commands/_lib/Invoke-WsaCommand.ps1:44-57`). Static finding | Decide: refuse non-manifest hosts, or document both as unbounded read-only probes in the manual and safety model. Acceptance: a fixture for whichever rule is chosen |
| P2 | Engine version is `0.1.0` in `engine/catalog.yaml:3` and `python/windows_admin/cli.py:68`, `1.1.0` in the plugin and engine manifests | Decide which version `doctor` should report, then add a test that the three agree or are named differently |
| P2 | Eight specialists have no three-positive, two-owned-negative set (`windows-system-inventory`, `windows-health-assessment`, `windows-active-directory-health`, `windows-security-analysis`, `windows-development-workstation`, `windows-kaizen-engine-and-product-improvement`, `windows-portability-doctrine`, `windows-desktop-e2e-testing`) | Add fixtures for four and raise `FULL_COVERAGE_FLOOR` to match |
| P2 | IIS version and Server 2025 guidance not established; Entra changes after June 2026 not read; Arc agent versions across a fleet not inventoried (all NOT_ASSESSED in `docs/research/currentness-2026-10-31.md`) | One scoped primary source per gap, recorded in the register |
| P2 | PowerShell fixtures never run on 7.6 LTS or on Windows PowerShell 5.1, the version the module manifest declares | Run the syntax check and fixtures on both once a runtime is allowed |
| P2 | Domain-specific portable-contract migration and further mutating tools (carried) | Unchanged |
| P2 | Two spellings of one status: `current-check-required` (36 rows) and `currentness-check-required` (2 book rows) in `engine/source-register.yaml` | Normalise in one commit; the gate's vocabulary accepts both today |

## Remote branch `origin/peterbamuhigire-patch-1`

Not touched. Read as instructed:

- `git diff origin/main...origin/peterbamuhigire-patch-1 --stat` prints nothing.
- `git rev-list --count origin/main..origin/peterbamuhigire-patch-1` is 0, and
  `git merge-base --is-ancestor` confirms the branch tip `ee73a54` (a merge of
  `main` dated 2026-07-11, after two README clean-up commits) is already an
  ancestor of `origin/main`. `main` is 64 commits ahead.
- Nothing on it is worth taking: it holds no commit that `main` lacks. Peter may
  delete the branch on the remote if he wants it gone; this pass did not.

## Cross-engine handoffs (no other engine edited)

Names are identifiers resolved through the device catalogue, not links.

- Windows `docs/safety-model.md` and Linux `AGENTS.md` and `linux-sysadmin/SKILL.md`:
  Windows uses R0 to R5 with `ShouldProcess`; Linux uses preview-first
  procedures. Unchanged from 29 October: keep the domain classes, carry named
  targets, authority, before and after, rollback and `NOT_ASSESSED` labels in
  shared handoffs.
- Windows `commands/_lib/Invoke-WsaCommand.ps1` and the coordination package's
  `hooks/destructive-bash-gate.js`: in this session a shell hook did block a
  recursive forced delete of a scratch directory, which shows interception works
  for shell commands. It says nothing about the PowerShell module, whose
  refusal is independently tested in-module. The hook that fired was loaded from
  the proposal engine's plugin copy; the coordination package should confirm
  which copy is canonical and that the copies agree.
- Windows `engine/source-register.yaml` `policy.portfolio_currentness_manifest`
  and the development engine's `docs/source-registers/skills-engine-currentness-2026-09.json`:
  the file exists and was modified on 2026-10-29; its broad portfolio pointer
  still cannot certify Windows target support, which the Windows scoped reviews
  cover. No edit made to the development engine.
- Coordination `catalog/engines.yaml` (lines 89-98) lists three validators for
  this engine (`validate_engine.py`, `routing_smoke_test.py`,
  `source_ingestion_guardrail.py`) and `released_commit: "132cbe9"`, which is
  an ancestor of this engine's starting HEAD, 20 commits behind. The engine's own
  `.skills-engine/engine-manifest.yaml` also declares the unit tests and,
  now, `source-currency`. The coordination package should refresh the commit and
  add `python -X utf8 scripts/check_source_register.py` in its own cycle.

## One small experiment for next time

With PowerShell available, write the refusal fixture for an expired maintenance
window against `Invoke-WseServiceState` (first finding above). It is one
fixture, one function, and the manifest validator now defines what a valid
window is, so the two can share the same interval rule.
