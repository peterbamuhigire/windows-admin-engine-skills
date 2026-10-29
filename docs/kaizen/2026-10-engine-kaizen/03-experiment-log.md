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

`pwsh -NoProfile -File scripts/test-service-state-fixture.ps1` passes nine
assertions in an offline disposable Linux PowerShell container. The fixture
executes the real service state and local-target functions, with synthetic
service commands and an explicit replacement for the Windows identity/result
adapter. Covered: no-mutation preview, remote refusal before lookup, lookup
failure, normal change, repeated no-change, partial-mutation recovery, timeout
recovery, failed recovery and unsupported original-state refusal. This is
state-machine proof, not Windows service/identity integration.

All three registered Python validators exit0; Python unittest reports23 passes.
PowerShell syntax reports79 files, zero findings. The Windows behaviour suite
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
accessed2026-10-29, distinguishes positional array splatting from named
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
scripts; all16 maintenance scripts and12 exported functions are accounted for.
Python validators and23 unit tests pass; PowerShell syntax checks80 files with
zero findings. No source behaviour was padded to appease a scanner.
