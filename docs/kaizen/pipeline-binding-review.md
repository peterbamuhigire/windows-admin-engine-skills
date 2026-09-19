# Pipeline binding and trace safety review

Author: Peter Bamuhigire | techguypeter.com | +256 784 464 178

This B26-A02 reference describes safe semantic binding for the service-state
controller. It treats PowerShell binding and tracing as observable mechanics,
not as permission to run a nested operation.

## Binding contract

Every controller request declares an entity `Kind` and `Namespace` (for
example, a service in the Windows service namespace). Direct, `ByValue`, and
`ByPropertyName` paths are accepted only when the incoming object has the
expected semantic entity. A process ID, job ID, display string, empty target,
or malformed target cannot bind to a consequential operation.

The acceptance oracle checks that a valid service object reaches the same target
resolution path as a direct request, while a process-shaped object and empty
name are rejected before any resource lookup or mutation.

## Trace boundary

`Trace-Command` is execution-capable instrumentation. A trace wrapper must
validate the nested operation, preserve the target and authority contract, and
honour `ShouldProcess`/`-WhatIf` before any mutation. Trace output is diagnostic
evidence and is never treated as an approval, success result, or target identity.
An unapproved nested mutation is rejected without execution.

Synthetic binding and trace cases are checked with:

```powershell
python -X utf8 -m unittest tests/python/test_kaizen_contracts.py -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

The fixture contains no host names, credentials, trace capture, or executable
nested command. Live remoting and mutation evidence are `NOT_ASSESSED`.
