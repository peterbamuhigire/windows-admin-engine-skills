# Typed controller and object-output contract

Author: Peter Bamuhigire | techguypeter.com | +256 784 464 178

This B26-A01 reference defines the boundary between a Windows operation
controller and its presentation layer. It extends the existing
`WindowsSkills.OperationResult` envelope and does not grant authority to change
a host.

## Domain result

Controllers return a typed object with `PSTypeName`
`WindowsSkills.OperationResult`, `SchemaVersion`, stable `OperationId`,
`Command`, a semantic `Target`, status, before/after state, verification,
rollback artifact, warnings, errors, and per-target outcomes. `Target` carries
`Kind`, `Name`, and optional `Fingerprint`; a controller request may also carry
an explicit entity `Namespace` and `EntityKind` so a process ID cannot be
mistaken for an operation or job identifier.

The allowed statuses are `NoChange`, `Succeeded`, `Failed`, `PendingReboot`,
`PartiallySucceeded`, and `Aborted`. A partial or aborted result remains
partial even when another target succeeds. An error or warning is structured
data and must not be replaced by formatted display text.

## Presentation boundary

Formatters may render a result for a human, JSON, or a table, but a formatter's
string is never accepted as controller input or evidence. The same synthetic
result must retain its status, target, verification, and per-target outcomes
through direct and presentation paths. Read-only calls must leave `Changed`
false and must not invoke mutation helpers.

Mutating public functions retain `[CmdletBinding(SupportsShouldProcess)]`,
`-WhatIf`, confirmation, target resolution, before-state capture, verification,
and rollback behaviour. This document does not weaken that boundary.

The synthetic contract is exercised with:

```powershell
python -X utf8 -m unittest tests/python/test_kaizen_contracts.py -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

The local checks prove object shape and preview behaviour only. Remote hosts,
domain controllers, management ownership, and production readiness remain
`NOT_ASSESSED`.
