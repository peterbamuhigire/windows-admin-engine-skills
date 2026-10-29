# Experiment log — 29 October 2026

## W1 — service refusal and recovery

Before: direct out-of-scope call could not construct a failure result because
`changed` was unset; a partial mutation exception bypassed recovery; timeout
recovery did not verify restored state. No host service was changed during
observation.

After: state is initialised before target access. The function rejects original
states without a supported inverse, treats mutation attempts conservatively,
and verifies restoration after transition error or timeout. Failed restoration
produces `Recovery=FAILED` and unknown after-state, never a success result.
The original operation remains Failed even when restoration succeeds.
The timeout bounds state polling after a service cmdlet returns; it does not
interrupt a hung `Start-Service`/`Stop-Service` invocation. That hung-call path
and Windows recovery behavior remain NOT_ASSESSED.

`pwsh -NoProfile -File scripts/test-service-state-fixture.ps1` passes nine
assertions in an offline disposable Linux PowerShell container. The fixture
executes the real service state and local-target functions, with synthetic
service commands and an explicit replacement for the Windows identity/result
adapter. Covered: no-mutation preview, remote refusal before lookup, lookup
failure, normal change, repeated no-change, partial-mutation recovery, timeout
recovery, failed recovery and unsupported original-state refusal. This is
state-machine proof, not Windows service/identity integration.

All three registered Python validators exit 0; Python unittest reports 23 passes.
PowerShell syntax reports 79 files, zero findings. The Windows behaviour suite
is separately NOT_ASSESSED on this Linux host because Windows identity APIs
are unavailable; the new fixture is registered in that suite for Windows CI.
No score uplift is assigned before final remeasurement. No change reverted.

## W2 — typed service wrapper

The service wrapper now declares its parameters and forwards their names and
values as a hashtable through both dispatcher layers. It preserves WhatIf and
Confirm and propagates Failed operation results as a nonzero process exit. Raw
string-array service arguments are rejected with a typed-entry-point message.
No expression evaluation or reconstructed command string is used. Microsoft
[about_Splatting](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.6),
accessed 2026-10-29, distinguishes positional array splatting from named
hashtable splatting; this is the relevant language contract.

The native wrapper fixture executes three invocations with the actual wrapper,
dispatcher, local target boundary and service function: stop preview, already
running no-change, and out-of-scope refusal. All three pass with zero fixture
mutations. The result adapter and OS service commands are explicitly synthetic.
These are three invocations of the one mutating WSA command, not three distinct
mutating tools; read-only WSA commands do not promise a WhatIf interface. The
Windows identity/integration gate remains NOT_ASSESSED.

W2 validation also found two scanner assumptions: command-catalogue parsing
recognised only backslash paths and positional action names; the manual gate
required backslash spelling. Both now accept the actual typed/POSIX-relative
form, and an unresolved command action fails the catalogue check. The existing
48-command catalogue remains unchanged. The manual documents both new fixture
scripts; all 16 maintenance scripts and 12 exported functions are accounted for.
Python validators and 23 unit tests pass; PowerShell syntax checks 80 files with
zero findings. No source behaviour was padded to appease a scanner.

## W3 — diagnosis before repair

The ranker now follows the existing hub rule for explicit unknown-cause
symptoms and diagnostic requests following a change, while an explicitly
confirmed cause keeps specialist routing. The file-share/patching task now
ranks troubleshooting first. A new plural share/service probe exposed missing
catalogue keywords; adding those exact resource aliases resolves that query.
The original 19 fixtures still rank first correctly; the expanded 29-fixture set
passes at both rank one and rank three, with five owned-negative primary-route
checks. These are lexical oracles, not a model-routing benchmark. Two specialists
now have at least three positive and two owned-negative cases.

## W4 — marketplace and capacity

The registered validator now enforces exact canonical skill paths, marketplace
identity/version, portable router bindings and a fixed 5,000-file ceiling on
both package and complete checkout. Six regression tests cover boundary counts,
Git/cache accounting, path/identity/duplicate failures, symlinks, malformed
metadata and accidental slash commands. Existing native CLI compatibility is
retained without a speculative Codex manifest or copied skill tree.

Native Claude exposed `commands/README.md` as an unintended 21st component. Its
content is preserved at `docs/operations/direct-command-tree.md`; a new guard
prevents recurrence. A fresh offline Claude install after the move exposes
exactly 20 intended skills. Codex local installation also succeeds; its baseline
prompt-input proof exposed 20/20 canonical paths. No model/hook execution or
public-directory claim was made. Manifest description and author metadata are
now explicit. The three device-specific router paths resolve through the
catalogue instead.

All three registered Python validators pass; all 29 Python tests pass. Additional
command-tree/manual checks pass with 48 commands, 17 maintenance scripts and 12
exported functions. Full-checkout and package counts remain below 5,000; final
release measurement recounts Git object growth.

## W5 — scoped currency and usable plans

Added reusable GPO pilot and evidence-first incident plans, linked from their
skills, and five routing probes for the newly touched GPO skill. All 34 routes
rank first, seven owned-negative checks pass, and three specialists now have
three positive and two owned-negative cases. The original baseline remains
frozen; its first-rank metric was subsequently measured as 19/19, correcting the
preparation's NOT_ASSESSED rather than claiming an improvement from zero.

The source register links a dated scoped review without resetting 48 existing
rows. A final official-page recheck corrected preparation's stale Server 2025
October B snapshot to its listed October OOB update. URL checking again returns
38/38 reachable; semantic support and fleet advisory closure are separate.
PowerShell patch support is now explicitly distinguished from the old fixture
runtime. The model policy is retained; no comparative paid evaluation or
running-root model change is claimed. All registered Python gates pass; the
Windows identity limitation remains. No change was reverted.
