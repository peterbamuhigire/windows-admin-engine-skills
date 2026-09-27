# Windows system administration activity records

WindowsSkills.Engine writes one minimal activity event whenever it constructs an
operation result. The public `Add-WseAdminActivity` cmdlet records a completed
engine-mediated task that did not use a WSE operation result. `Get-WseAdminActivityReport`
generates a date-ranged Markdown report and can read multiple activity roots,
including an exported Linux record directory.

## Data and storage

Records use schema `chwezi.system-admin-activity.v1`, shared with Linux. The
canonical field contract and current research are in
`chwezi-engine-agents/docs/operations/system-admin-activity-record-contract-2026-09.md`.
The default store is monthly JSON Lines under
`[Environment]::GetFolderPath(LocalApplicationData)\Chwezi\WindowsAdmin\activity`.
It is per-user, outside the checkout, and does not require elevation. Set
`CHWEZI_ACTIVITY_ROOT` for automatic WSE records and default report lookup, or
pass `-ActivityRoot` to `Add-WseAdminActivity`; create and permission a shared
root under the relevant host policy.

The record omits usernames, hostnames, raw command text/arguments, command
output, secrets, and snapshots. It includes operation ID/name, UTC timestamp,
broad activity type, target scope, result status, changed flag, and a short
summary. Detailed data stays in existing evidence packs or Windows Event Logs.
JSONL is append-oriented, not tamper-proof. Reports include only available
records and cannot establish that unrecorded actions did not happen.

## Use

WSE cmdlets append their minimal activity record automatically. For a separate
workflow completed outside WSE, append a concise record:

```powershell
Add-WseAdminActivity `
  -ActivityType security `
  -Operation 'review local security posture' `
  -Status succeeded `
  -TargetScope local `
  -Changed $false `
  -Summary 'Reviewed the scoped control set; no host settings were changed.' `
  -EvidenceReference 'case-2026-09-27-security-review'
```

Create a report for the last 30 days (default):

```powershell
$report = Get-WseAdminActivityReport
$report.Markdown
```

Or save a UTC-bounded report:

```powershell
Get-WseAdminActivityReport `
  -FromUtc ([datetime]::Parse('2026-09-01T00:00:00Z')) `
  -ToUtc ([datetime]::Parse('2026-09-30T23:59:59Z')) `
  -OutputPath './reports/system-admin-2026-09.md'
```

Pass multiple `-RecordRoot` directories to combine exports from Linux or other
Windows accounts. The report deduplicates event IDs, counts malformed records,
and retains blocked/failed/partial outcomes. It does not install a service,
scheduled task, or updater. See the cross-platform
[activity-record contract](../../../chwezi-engine-agents/docs/operations/system-admin-activity-record-contract-2026-09.md)
for evidence sources and the separately researched background-operation options.
