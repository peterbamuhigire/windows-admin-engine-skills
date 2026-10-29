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
