# Windows Administration Engine command and script manual

Manual version: 0.1.0  
Engine release: 0.1.0  
Last reviewed: 2026-08-12

This is the operator reference for the command accelerators, PowerShell module,
and repository-maintenance scripts in this checkout. The generated inventory in
`engine/command-catalog.json` remains the machine-readable source of truth; this
manual explains when and how a human operator uses each entry.

## 1. Operating boundary

- Release 0.1 operates on the local Windows machine. Module commands reject a
  non-local `-ComputerName`; fleet manifests are validated but targets are not
  contacted.
- All direct commands are R0 observation commands except
  `wsa-service-state`, which is an R2 local service mutation.
- `-EvidenceRoot` writes redacted evidence files and is therefore an intentional
  local filesystem write, even when the Windows operation itself is read-only.
- A successful discovery command proves only what it observed. Values such as
  `NOT_ASSESSED`, warnings, and partial results must not be converted into claims
  of health, compliance, recoverability, or absence.
- Some discovery commands need an elevated terminal to see complete system
  state. Elevation does not expand the approved operation or target scope.
- Backup status is not a restore test; security snapshots are not compliance
  certifications; tool availability is not proof that a tool works.

## 2. Install commands on `PATH`

Run the installer from the repository root. Preview first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-windows-admin.ps1 -WhatIf
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-windows-admin.ps1 -Confirm:$false
```

The installer is the single install, update, and repair command. It removes
stale engine-owned entries from the current and previously registered checkout,
adds `commands` and all current subdirectories to the user `PATH`, sets
`WINDOWS_ADMIN_ENGINE_ROOT`, checks command-name collisions, deduplicates
entries, verifies the written state, and restores the prior environment if the
write or verification fails. It stops if the proposed user `PATH` exceeds the
8,191-character compatibility gate. Unrelated `PATH` entries are preserved.
Open a new terminal after installation.

Run the same installer after an update that adds, renames, or removes a command
directory, or after moving the checkout. Existing commands are read directly
from the checkout, and new commands inside an already registered directory need
no refresh. Skill-only changes do not affect `PATH`. Do not uninstall before an
update; the uninstall script is only for removing the engine integration.

Use `-ForceCollision` only after reviewing every reported collision. Use
`-SkipPathLengthCheck` only when the affected shells and deployment tooling are
known to support the resulting length. A shorter alternative is to add only
`commands\bin` to `PATH` and use the `wsa <subcommand>` dispatcher.

Remove only the engine's user-environment entries; repository files are kept:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-windows-admin.ps1 -WhatIf
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-windows-admin.ps1 -Confirm:$false
```

## 3. Invocation and output conventions

Every direct command has a PowerShell `.ps1` launcher and a same-named `.cmd`
launcher. The `.cmd` launcher makes a command usable from Command Prompt and
from shells that resolve executable extensions. The PowerShell launcher sends
all arguments to `commands\bin\wsa.ps1`.

These forms are equivalent after installation:

```powershell
wsa-inventory -EvidenceRoot C:\WindowsAdminEvidence
wsa inventory -EvidenceRoot C:\WindowsAdminEvidence
```

Before installation, invoke the dispatcher from the checkout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\commands\bin\wsa.ps1 inventory
```

Module-backed commands return an operation object with status, target, before
and after data, verification state, warnings, errors, and evidence path. Native
utility commands return their normal text and exit code. PowerShell discovery
commands return objects suitable for filtering or export:

```powershell
wsa-processes | Where-Object WorkingSet64 -gt 1GB | Format-Table
wsa-hotfixes | Export-Csv .\hotfixes.csv -NoTypeInformation
wsa-inventory | ConvertTo-Json -Depth 12
```

Exit code `0` means the launcher completed successfully; a nonzero code means
validation, routing, a native utility, or the launcher failed. For operation
objects, also inspect `Status`, `Errors`, `Warnings`, and `Verification`; shell
success does not erase a `PartiallySucceeded` or `NOT_ASSESSED` result.

## 4. Engine discovery and validation

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-list` | Lists specialist skill IDs, risk class, maturity, and category. | `wsa-list` |
| `wsa-route` | Ranks specialist skills for a plain-language operator request; it does not execute the request. | `wsa-route "check AD replication health"`; use the Python CLI directly for `--json`. |
| `wsa-doctor` | Checks that required exported module commands loaded and reports module/runtime versions. Live-lab state remains `NOT_ASSESSED`. | `wsa-doctor` |
| `wsa-validate` | Runs structural, routing, source-ingestion, command-tree, operator-manual, and PowerShell syntax gates. | `wsa-validate`; run from any directory after installation. Requires Python and Windows PowerShell. |
| `wsa-evidence-validate` | Validates an evidence-pack directory, its manifest, required operation fields, and recorded hashes. | `wsa-evidence-validate C:\WindowsAdminEvidence\inventory-...` |

## 5. Inventory and system health

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-inventory` | Returns local computer, domain role, hardware, OS/build, BIOS, PowerShell, elevation, reboot indicators, fixed volumes, and installed server roles where available. | `wsa-inventory [-ComputerName LOCAL] [-EvidenceRoot PATH]`; only local aliases are accepted. |
| `wsa-health` | Evaluates pending reboot, fixed-disk free space, automatic services that are not running, and recent System critical/error events. | `wsa-health [-MinimumFreePercent 15] [-EventLookbackHours 24] [-EvidenceRoot PATH]`; thresholds: free percent 1–99, lookback 1–168 hours. Findings require operator interpretation. |
| `wsa-software` | Enumerates installed-application metadata from the 64-bit and 32-bit machine uninstall registry locations. | `wsa-software`; it does not inventory every package technology or per-user installation. |
| `wsa-drivers` | Lists signed PnP-driver metadata including device, provider, version, date, INF, and signature state. | `wsa-drivers`; uses `Win32_PnPSignedDriver`. |
| `wsa-certificates` | Lists metadata for certificates in `Cert:\LocalMachine\My`. | `wsa-certificates`; it never emits private keys or secret material. Reading the machine store may require elevation. |

## 6. Networking and time

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-network` | Captures adapters, IP addresses, routes, DNS client servers, firewall profiles, and TCP listeners when their cmdlets are available. | `wsa-network [-ComputerName LOCAL] [-EvidenceRoot PATH]`; unavailable providers are recorded as warnings. |
| `wsa-dns-test` | Resolves a DNS name with `Resolve-DnsName`, falling back to .NET DNS when needed. | `wsa-dns-test <name>`; example: `wsa-dns-test dc01.example.test`. |
| `wsa-port-test` | Tests a TCP connection and reports `ComputerName`, `RemoteAddress`, `RemotePort`, and success. | `wsa-port-test <computer> <port>`; example: `wsa-port-test dc01.example.test 5985`. This tests reachability, not application correctness or authorization. |
| `wsa-listeners` | Lists local listening TCP endpoints, owning process IDs, and creation times. | `wsa-listeners`; elevated execution can improve completeness. |
| `wsa-time-status` | Runs `w32tm /query /status` and `/query /source`. | `wsa-time-status`; preserves the native exit code. Domain time health may require comparison with DC and event evidence. |

## 7. Identity and Active Directory

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-local-accounts` | Lists local account identity and state. Uses `Get-LocalUser`, with a CIM fallback. | `wsa-local-accounts`; the fallback exposes slightly different fields. |
| `wsa-local-admins` | Lists members of the built-in Administrators group, resolving the localized group name from SID `S-1-5-32-544`. | `wsa-local-admins`; requires `Get-LocalGroupMember`; elevation may be required for complete results. |
| `wsa-ad-health` | Returns forest/domain modes, FSMO owners, domain controllers, and a `repadmin /replsummary` observation. | `wsa-ad-health [-ComputerName LOCAL] [-EvidenceRoot PATH]`; requires the ActiveDirectory module and domain connectivity. It does not run full DCDiag or per-partner verification. |
| `wsa-ad-replication` | Runs the native replication summary. | `wsa-ad-replication`; requires `repadmin.exe`, domain access, and suitable directory permissions. |
| `wsa-ad-fsmo` | Reports domain and forest FSMO role holders. | `wsa-ad-fsmo`; requires the ActiveDirectory module. |
| `wsa-ad-dcs` | Lists discovered domain controllers, sites, addresses, global-catalog state, and operation-master roles. | `wsa-ad-dcs`; requires the ActiveDirectory module. |

## 8. Group Policy

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-gp-result` | Runs `gpresult /r` to show the Resultant Set of Policy summary for the current context. | `wsa-gp-result [gpresult arguments]`; for example, `wsa-gp-result /scope computer`. Complete computer results normally require elevation. It makes no policy change. |

## 9. Security posture

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-security` | Returns available Defender, BitLocker, Secure Boot, and firewall-profile observations in one operation envelope. | `wsa-security [-ComputerName LOCAL] [-EvidenceRoot PATH]`; warnings and policy ownership must be reviewed. It is not a compliance verdict. |
| `wsa-firewall-status` | Lists firewall profile state and default inbound/outbound behavior. | `wsa-firewall-status`; it does not enumerate or change rules. |
| `wsa-defender-status` | Lists key Microsoft Defender service, protection, signature, and scan-age fields. | `wsa-defender-status`; requires Defender cmdlets and sufficient access. |
| `wsa-bitlocker-status` | Lists volume, protection, encryption method, and percentage metadata. | `wsa-bitlocker-status`; never returns recovery passwords or key protectors. Elevation may be required. |
| `wsa-audit-policy` | Runs `auditpol /get /category:*` to display effective audit policy. | `wsa-audit-policy`; preserves the native exit code and makes no audit-policy change. |

## 10. Patching and reboot discovery

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-hotfixes` | Lists installed hotfix metadata in descending installation-date order. | `wsa-hotfixes`; `Get-HotFix` is not a complete inventory of every servicing technology. |
| `wsa-pending-reboot` | Returns the engine's local pending-reboot observation and reasons. | `wsa-pending-reboot`; absence of detected indicators is not permission to patch or reboot. |

## 11. Storage, services, shares, and tasks

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-storage` | Returns physical disk metadata, fixed logical volumes, and Windows service state in an operation envelope. | `wsa-storage [-ServiceName NAME] [-EvidenceRoot PATH]`; no disk mutation or cleanup occurs. |
| `wsa-service` | Uses the same snapshot function, optionally narrowing service output by exact service name. | `wsa-service -ServiceName W32Time [-EvidenceRoot PATH]`; omitting `-ServiceName` returns all services. |
| `wsa-service-state` | Starts or stops one local service, verifies the result, and records rollback state. This is the only R2 accelerator in release 0.1. | Preview: `wsa-service-state -Name W32Time -DesiredState Running -ChangeAuthority CHG-2026-0042 -MaintenanceWindow '2026-08-12T21:00+03:00' -WhatIf`. Real execution requires the same authority/window fields, appropriate elevation, and confirmation (or an explicitly governed `-Confirm:$false`). Name characters are restricted; timeout is 1–300 seconds. If verification fails, the command attempts to restore the prior running/stopped state. |
| `wsa-shares` | Lists SMB share name, path, description, encryption, enumeration mode, and user limit. | `wsa-shares`; requires SMB cmdlets and suitable access. |
| `wsa-smb-sessions` | Lists active SMB sessions and connection properties. | `wsa-smb-sessions`; normally requires elevation. It does not close sessions. |
| `wsa-open-files` | Lists server-side SMB open-file records. | `wsa-open-files`; normally requires elevation. It does not close files. |
| `wsa-tasks` | Lists scheduled task path, name, state, author, and description. | `wsa-tasks`; it does not display every action/trigger detail or change tasks. |

## 12. IIS

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-iis-status` | Returns IIS websites, bindings, physical paths, and application-pool state/runtime metadata. | `wsa-iis-status`; requires the WebAdministration module and an IIS-capable host. It does not start, stop, or reconfigure IIS. |

## 13. Virtualization, WSL, and containers

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-hyperv-status` | Returns VM, virtual-switch, and checkpoint inventory. | `wsa-hyperv-status`; requires the Hyper-V module and appropriate Hyper-V permissions. It does not alter VM state. |
| `wsa-wsl-status` | Runs `wsl --status` and `wsl --list --verbose`. | `wsa-wsl-status`; requires `wsl.exe`; preserves the last native exit code. |
| `wsa-containers-status` | Reports whether Docker, Podman, containerd, and nerdctl commands resolve and where. | `wsa-containers-status`; runtime health is deliberately `NOT_ASSESSED`. |

## 14. Observability and troubleshooting

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-events` | Collects recent events from one or more Windows logs into an operation envelope. | `wsa-events [-LogName System,Application] [-LookbackHours 24] [-MaxEvents 250] [-EvidenceRoot PATH]`; ranges are 1–720 hours and 1–5,000 events per log. The verification block reports possible truncation. Event messages may contain sensitive operational data; evidence redaction still requires review. |
| `wsa-processes` | Lists the 50 processes with the highest accumulated CPU value, plus memory and start time. | `wsa-processes`; protected processes may expose incomplete fields. This is a point-in-time list, not a performance diagnosis. |
| `wsa-performance-sample` | Samples total CPU, available memory, and average physical-disk transfer latency. | `wsa-performance-sample`; fixed collection is five samples at one-second intervals. Counter availability and localized counter names can vary. |
| `wsa-startup` | Lists startup commands from `Win32_StartupCommand`. | `wsa-startup`; it does not represent every possible persistence mechanism. |

## 15. Backup and recovery observations

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-backup-status` | Reports Windows Server Backup feature information where available and the `wbengine` service state. | `wsa-backup-status`; `RecoveryTest` is always `NOT_ASSESSED` in 0.1. Never infer recoverability from service/feature presence. |
| `wsa-vss-status` | Runs `vssadmin list writers` and preserves its exit code. | `wsa-vss-status`; use elevated PowerShell. Healthy writers are necessary for many backups but are not proof of a valid backup or restore. |

## 16. Development workstation

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-toolchain` | Reports command resolution and path for Windows PowerShell, PowerShell 7, Python, Python launcher, Git, .NET, Node.js, npm, winget, WSL, and VS Code. | `wsa-toolchain`; version and functional health remain `NOT_ASSESSED`. |

## 17. Fleet manifest safety

| Command | Purpose and output | Syntax and important notes |
| --- | --- | --- |
| `wsa-fleet-validate` | Validates a fleet-manifest JSON file for schema version, nonempty unique targets, blast-radius limit, and per-target fingerprint. | `wsa-fleet-validate .\fleet-manifest.json`; validation contacts no target and reports `contact_attempted=false`. It does not authorize fleet execution. |

## 18. `wsa` dispatcher subcommands

The dispatcher syntax is `wsa <subcommand> [arguments]`. Each direct command
maps by removing the `wsa-` prefix: `wsa-inventory` is `wsa inventory`,
`wsa-ad-health` is `wsa ad-health`, and so on. Supported subcommands are:

```text
list route validate doctor evidence-validate
inventory health software drivers certificates
network dns-test port-test listeners time-status
local-accounts local-admins ad-health ad-replication ad-fsmo ad-dcs
gp-result security firewall-status defender-status bitlocker-status audit-policy
hotfixes pending-reboot storage service service-state shares smb-sessions
open-files tasks iis-status hyperv-status wsl-status containers-status
events processes performance-sample startup backup-status vss-status
toolchain fleet-validate
```

An unknown subcommand fails closed and suggests `wsa-list` or `wsa-route`.
`commands\bin\wsa.cmd` is the Command Prompt entry point and
`commands\bin\wsa.ps1` is the PowerShell dispatcher.

## 19. Exported PowerShell module functions

Import the module when composing pipelines or building another approved tool:

```powershell
Import-Module .\powershell\WindowsSkills.Engine\WindowsSkills.Engine.psd1 -Force
```

| Function | Parameters | Use |
| --- | --- | --- |
| `Get-WseSystemInventory` | `-ComputerName`, `-EvidenceRoot` | The module primitive behind `wsa-inventory`. |
| `Test-WseSystemHealth` | `-ComputerName`, `-MinimumFreePercent`, `-EventLookbackHours`, `-EvidenceRoot` | The health-assessment primitive behind `wsa-health`. |
| `Get-WseNetworkSnapshot` | `-ComputerName`, `-EvidenceRoot` | The network snapshot behind `wsa-network`. |
| `Get-WseAdHealth` | `-ComputerName`, `-EvidenceRoot` | The AD discovery operation behind `wsa-ad-health`. |
| `Get-WseSecuritySnapshot` | `-ComputerName`, `-EvidenceRoot` | The combined security snapshot behind `wsa-security`. |
| `Get-WseStorageServiceSnapshot` | `-ComputerName`, `-ServiceName`, `-EvidenceRoot` | The shared storage/service snapshot behind `wsa-storage` and `wsa-service`. |
| `Get-WseEventEvidence` | `-ComputerName`, `-LogName`, `-LookbackHours`, `-MaxEvents`, `-EvidenceRoot` | The event collector behind `wsa-events`. |
| `Invoke-WseServiceState` | `-Name`, `-DesiredState`, `-ChangeAuthority`, `-MaintenanceWindow`, `-ComputerName`, `-TimeoutSeconds`, `-EvidenceRoot`, `-WhatIf`, `-Confirm` | The controlled R2 service-state primitive. Use the safety procedure in section 11. |
| `Write-WseEvidencePack` | pipeline `-OperationResult`, `-EvidenceRoot`, `-WhatIf`, `-Confirm` | Redacts an operation value, writes `operation.json`, hashes it, and writes `manifest.json`. |
| `Test-WseEngine` | none | Checks the imported module surface; it is not a live infrastructure test. |

All `-ComputerName` parameters are local-only in release 0.1. Allowed aliases
are resolved by the module; remote orchestration must not be simulated by
passing a remote name.

## 20. Python operator CLI

`scripts\windows-admin.ps1` sets `PYTHONPATH` for this checkout and invokes the
Python package. `scripts\windows-admin.cmd` is its Command Prompt wrapper.

```powershell
.\scripts\windows-admin.ps1 list
.\scripts\windows-admin.ps1 route "inspect low disk space" --json
.\scripts\windows-admin.ps1 validate-operation .\operation.json
.\scripts\windows-admin.ps1 validate-evidence .\.evidence\inventory-...
.\scripts\windows-admin.ps1 doctor
```

The same interface can be invoked as
`python -X utf8 -m windows_admin.cli --repo <ENGINE_ROOT> <subcommand>` after the
package is installed or the repository's `python` directory is on
`PYTHONPATH`.

## 21. Repository maintenance scripts

Run these from the repository root unless a row says otherwise.

| Script | Effect and usage |
| --- | --- |
| `scripts\generate_command_catalog.py` | Regenerates `engine\command-catalog.json` from direct command launchers. This writes a tracked file: `python -X utf8 scripts\generate_command_catalog.py`. Review the diff afterward. |
| `scripts\routing_smoke_test.py` | Tests routing fixtures and returns nonzero on a mismatch: `python -X utf8 scripts\routing_smoke_test.py`. |
| `scripts\source_ingestion_guardrail.py` | Checks that restricted source text was not copied into implementation areas: `python -X utf8 scripts\source_ingestion_guardrail.py`. |
| `scripts\validate_command_tree.py` | Checks launcher/wrapper/catalog agreement and command naming: `python -X utf8 scripts\validate_command_tree.py`. |
| `scripts\validate_engine.py` | Validates catalogue records, referenced skills, schemas, and repository structure: `python -X utf8 scripts\validate_engine.py`. |
| `scripts\validate_fleet_manifest.py` | Validates one manifest without contacting targets: `python -X utf8 scripts\validate_fleet_manifest.py tests\fixtures\fleet-manifest.valid.json`. |
| `scripts\validate_operator_manual.py` | Confirms that every catalogued command, dispatcher, exported module function, and script in `scripts` is named in this manual: `python -X utf8 scripts\validate_operator_manual.py`. |
| `scripts\verify_source_urls.py` | Makes network requests to verify registered official-source URLs. Print JSON to stdout or use `--out PATH`: `python -X utf8 scripts\verify_source_urls.py --out .\source-url-report.json`. This is not part of offline CI because network state is variable. |
| `scripts\test-powershell-syntax.ps1` | Parses every repository `.ps1` and fails on PowerShell syntax errors: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-powershell-syntax.ps1`. |
| `scripts\test-powershell.ps1` | Imports the module, runs doctor and local inventory, proves the service mutation remains unchanged under `-WhatIf`, and runs module plus installer-reconciliation Pester tests when installed: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-powershell.ps1`. It reads live local state but its service and installer tests are preview-only. |
| `scripts\install-windows-admin.ps1` | Idempotently installs, updates, or repairs the user `PATH` and `WINDOWS_ADMIN_ENGINE_ROOT` state described in section 2. It cleans stale paths and rolls back failed writes. Supports `-WhatIf`, `-Confirm`, `-ForceCollision`, and `-SkipPathLengthCheck`. |
| `scripts\uninstall-windows-admin.ps1` | Previews or removes only this engine's user-environment entries. It never deletes repository files. Supports `-WhatIf` and `-Confirm`. |
| `scripts\windows-admin.ps1` | PowerShell wrapper for the Python operator CLI described in section 20. |
| `scripts\windows-admin.cmd` | Command Prompt wrapper for `scripts\windows-admin.ps1`; returns its exit code. |

## 22. Evidence workflow

Choose a protected evidence root appropriate for the data classification:

```powershell
$result = wsa-health -EvidenceRoot C:\WindowsAdminEvidence
$result.Status
$result.Warnings
wsa-evidence-validate $result.EvidencePath
```

Each evidence directory contains `operation.json` and `manifest.json`. The
manifest records a SHA-256 hash and verdict. Redaction reduces common secret
exposure but is not a substitute for access control, retention limits, or human
review before sharing. Do not place evidence in source control.

## 23. Troubleshooting sequence

1. Confirm resolution with `Get-Command wsa -All` and
   `Get-Command wsa-inventory -All`; unexpected duplicates indicate a collision.
2. Run `wsa-doctor` to check the module surface.
3. Run `wsa-validate` to check repository and launcher integrity.
4. Read the complete error and warnings. Missing RSAT, WebAdministration,
   Hyper-V, SMB, Defender, BitLocker, performance-counter, or native Windows
   utilities are platform/prerequisite failures, not permission to install or
   reconfigure them automatically.
5. Re-run discovery from an elevated terminal only when that access is approved.
6. For a failed R2 service change, preserve the result/evidence, inspect the
   recorded rollback artifact and observed state, and escalate rather than
   retrying blindly.

## 24. Maintainer rule

When adding, renaming, or removing a command or script:

1. update the implementation and tests;
2. regenerate `engine\command-catalog.json` when the command tree changes;
3. update this manual in the matching category;
4. run `python -X utf8 scripts\validate_operator_manual.py` and `wsa-validate`;
5. review examples for safety, privilege, output, and prerequisite accuracy.

The concise generated overview remains at
`docs\operations\command-catalog.md`; this file is the explanatory operator
manual.
