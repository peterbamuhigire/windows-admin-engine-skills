# Idempotent installer evidence

## Artifact identity

| Field | Value |
|---|---|
| Project | Windows Administration Skills Engine |
| Deliverable | Single-command install, update, and repair workflow |
| Owner | Peter Bamuhigire |
| Reviewer | Codex repository checks; human review pending |
| Date | 2026-08-12 |
| Related skills | `deployment-release-engineering`, `advanced-testing-strategy`, `observability-monitoring`, `anti-ai-slop`, `ai-slop-audit` |

## Decision record

| Decision | Rationale | Alternative rejected | Reversal trigger |
|---|---|---|---|
| Make `scripts/install-windows-admin.ps1` reconcile state on every run | One command now covers first install, repository updates, renamed command directories, moved checkouts, and repair | Requiring uninstall followed by install left stale paths between two operator actions | Reopen if commands move to a packaged shim directory with a different installation contract |
| Limit cleanup to the current and previously registered engine command roots | Removes obsolete engine entries without claiming ownership of unrelated `PATH` values | Removing every missing `PATH` entry could alter other software installations | Reopen only with a separate, explicitly authorised user-environment cleanup tool |
| Keep `uninstall-windows-admin.ps1` for explicit removal only | Update and removal are different operator intentions | Deleting the uninstall path would prevent a scoped engine removal | Reopen if a future command exposes explicit `Install`, `Repair`, and `Remove` actions |

## Behaviour contract

| Situation | Required user action |
|---|---|
| Existing command file edited | None; the registered path points to the checkout |
| New command added inside an already registered directory | None |
| Skill added or edited without a command | None |
| Command directory added, renamed, or removed | Run `scripts/install-windows-admin.ps1` once |
| Repository checkout moved | Run `scripts/install-windows-admin.ps1` once from the new root |
| Engine integration should be removed | Run `scripts/uninstall-windows-admin.ps1` |

## Safety and recovery

- `-WhatIf` prints the proposed mode, engine-owned changes, counts, collision
  result, and proposed length without changing either user or process state.
- Unrelated `PATH` entries retain their order and are not classified as
  engine-owned.
- Command-name collisions outside the current or previously registered engine
  roots remain blocking unless the operator explicitly uses `-ForceCollision`.
- The proposed user `PATH` remains subject to the 8,191-character compatibility
  gate unless the operator explicitly uses `-SkipPathLengthCheck`.
- A real write verifies both user `PATH` and `WINDOWS_ADMIN_ENGINE_ROOT`. Failure
  triggers restoration of the prior user and process environments; incomplete
  rollback is reported as such.
- The plan does not print the complete user `PATH`.

## Test evidence

| Check | Result |
|---|---|
| Stale numbered paths | Two fixture paths removed in one `-WhatIf` update |
| Unrelated path preservation | Fixture retained one unrelated directory |
| Current command discovery | 51 current command directories proposed |
| Idempotence | Second fixture run returned `Mode=NoChange`, `Changed=false` |
| Moved checkout | Two paths under a previously registered root removed |
| Test override safety | Override without `-WhatIf` refused |
| Current user preview | `Mode=NoChange`, 0 stale, 0 added, 51 reused, 0 collisions |
| Plan data minimisation | Full proposed user `PATH` absent from output |
| Pester installer tests | 4 passed, 0 failed |
| PowerShell module tests | 3 passed, 0 failed |
| PowerShell syntax | 71 files, 0 findings |
| Python unit tests | 10 passed |
| Engine/routing/command/manual gates | 0 findings or failures |

All installer and service-control tests used `-WhatIf`. No user-environment
write, remote connection, service change, reboot, or target mutation was
performed for this deliverable.

## Operational signals

The installer emits `Mode`, `Changed`, engine roots, stale/added/reused counts,
command and directory counts, collision count, preserved-directory count, and
proposed length. These fields answer whether an update is needed and what the
installer owns without logging unrelated path contents.

## Anti-slop audit

Verdict: A (clean). Genericness score: 5/100 using the written-content and code
rubrics. The implementation has named ownership boundaries, deterministic
fixtures, failure recovery, explicit residual risk, and no placeholder code,
fabricated dependency, secret, or unsupported readiness claim.

## Release verdict

| Gate | Verdict | Note |
|---|---|---|
| Correctness | PASS | Install, update, moved-checkout, and no-change cases tested |
| Safety | PASS | R1 preview, scoped ownership, verification, and rollback present |
| Data minimisation | PASS | Full user `PATH` is not emitted |
| Documentation | PASS | README and operator manual explain when a refresh is required |
| Live environment write | NOT_ASSESSED | Intentionally not authorised for this change |

Final decision: ready for human review and community publication.
