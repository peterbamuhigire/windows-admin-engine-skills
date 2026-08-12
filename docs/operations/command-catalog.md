# Direct command catalogue

All commands are stored under `commands/<category>/<subcategory>/` and use the
`wsa-` prefix. They work without an AI session.

For command syntax, prerequisites, privileges, output interpretation, module
functions, installers, and repository scripts, use the full
[command and script manual](commands-and-scripts-manual.md).

| Category | Commands | Mutation |
|---|---|---|
| Engine | `wsa-list`, `wsa-route`, `wsa-validate`, `wsa-doctor`, `wsa-evidence-validate`, `wsa <subcommand>` | no |
| Inventory/health | `wsa-inventory`, `wsa-health`, `wsa-software`, `wsa-drivers`, `wsa-certificates` | evidence write only |
| Network | `wsa-network`, `wsa-dns-test`, `wsa-port-test`, `wsa-listeners`, `wsa-time-status` | no |
| Identity | `wsa-local-accounts`, `wsa-local-admins`, `wsa-ad-health`, `wsa-ad-replication`, `wsa-ad-fsmo`, `wsa-ad-dcs` | no |
| Group Policy | `wsa-gp-result` | no |
| Security | `wsa-security`, `wsa-firewall-status`, `wsa-defender-status`, `wsa-bitlocker-status`, `wsa-audit-policy` | no |
| Patching | `wsa-hotfixes`, `wsa-pending-reboot` | no |
| Storage/services | `wsa-storage`, `wsa-service`, `wsa-shares`, `wsa-smb-sessions`, `wsa-open-files`, `wsa-tasks` | no |
| Controlled service | `wsa-service-state` | R2; authority, window, preview/confirm |
| IIS | `wsa-iis-status` | no |
| Virtualisation | `wsa-hyperv-status`, `wsa-wsl-status`, `wsa-containers-status` | no |
| Observability | `wsa-events`, `wsa-processes`, `wsa-performance-sample`, `wsa-startup` | no |
| Recovery | `wsa-backup-status`, `wsa-vss-status` | no; restore remains blocked |
| Development | `wsa-toolchain` | no |
| Fleet | `wsa-fleet-validate` | validates only; contacts no target |

## Examples

```powershell
wsa-inventory -EvidenceRoot C:\WindowsAdminEvidence
wsa-health -MinimumFreePercent 20 -EventLookbackHours 48
wsa-dns-test dc01.example.test
wsa-port-test dc01.example.test 5985
wsa-events -LogName System,Application -LookbackHours 4 -MaxEvents 100
wsa-service -ServiceName W32Time
wsa-service-state -Name W32Time -DesiredState Running `
  -ChangeAuthority CHG-2026-0042 -MaintenanceWindow '2026-08-12T21:00+03:00' `
  -EvidenceRoot C:\WindowsAdminEvidence -WhatIf
```

The service command is the only mutation accelerator in 0.1. Run it first with
`-WhatIf`; a real change is local-only and uses `ShouldProcess`.
