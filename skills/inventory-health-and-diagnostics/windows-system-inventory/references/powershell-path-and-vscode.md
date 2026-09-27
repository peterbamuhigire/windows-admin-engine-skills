# Diagnose a missing CLI in a PowerShell terminal

Run this inside the affected PowerShell terminal:

```powershell
Get-WseSystemInventory -ExecutableName codex
```

Executable resolution is opt-in. The result reports whether PowerShell resolves
the executable and whether its resolved directory appears in the current
process, user, or machine PATH. It also records the diagnostic process ID,
parent process name, terminal host name, and UTC observation time. It does not
include PATH values or resolved executable paths.

When process lookup misses the command, the diagnostic checks common Windows
launchers (`.exe`, `.com`, `.bat`, `.cmd`, and `.ps1`) in persisted PATH entries.
It reports only the matching directory's membership flags.

Windows processes receive an environment block when they are created. By
default, a child inherits a copy from its parent, though the parent may supply a
different block. A comparison in the affected terminal can therefore show that
the CLI directory is in the persisted user PATH but absent from that terminal's
process PATH. The report describes the current process; it does not inspect or
repair another process's environment.

If the command is absent from process, user, and machine PATH resolution, mark
its location `NOT_ASSESSED` and check the installation owner. Do not replace or
append the complete PATH as a generic repair. Resolve the management owner,
preview any authorised per-user change, and use a fresh process to verify it.

## Source

- Microsoft, [Environment Variables](https://learn.microsoft.com/windows/win32/procthread/environment-variables), accessed 2026-09-27. Supports the environment-block inheritance and parent-supplied-block statements above. It does not prove the environment of a particular VS Code window or terminal; collect that from the affected process context.
