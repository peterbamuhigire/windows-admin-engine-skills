# Linux-to-Windows capability crosswalk

| Linux family | Windows owner | Native boundary | 0.1 status |
|---|---|---|---|
| Provisioning/packages | windows-development-workstation, windows-patch-management | roles/features, WinGet, servicing | NOT_ASSESSED |
| Users/access/secrets | windows-identity-lifecycle | local SAM, AD DS, LAPS, JEA | NOT_ASSESSED |
| Networking/DNS | windows-network-admin | NetTCPIP, DnsClient, firewall, WinRM | PARTIAL |
| Web/mail | windows-iis | IIS/HTTP.sys; Exchange is separate | NOT_ASSESSED |
| Services/virtualisation | windows-storage-files-services, windows-hyper-v | SCM, tasks, Hyper-V | PARTIAL |
| Storage/filesystems | windows-storage-files-services | NTFS/ReFS, SMB/DFS, VSS | PARTIAL |
| Security/hardening | windows-security-analysis, windows-group-policy | Defender, BitLocker, GPO/MDM/SCT | PARTIAL assessment only |
| Observability/logs | windows-health-assessment, windows-troubleshooting | Event Log, counters, ETW/WER | PARTIAL |
| Recovery | windows-backup-recovery | Windows Server Backup, VSS, system state | NOT_ASSESSED |
| Automation | WindowsSkills.Engine and commands tree | PowerShell-first, Python support | LAB_VALIDATED locally |
| Databases | external database skills | product-owned modules/adapters | DEFERRED |
| Containers | windows-hyper-v | Windows containers/WSL | NOT_ASSESSED |
| Performance/kernel | windows-troubleshooting | counters, WPR/WPA, dumps, WinDbg | PARTIAL |
| Compliance/audit | windows-security-analysis | versioned baselines and evidence | PARTIAL, no certification |
| Fleet/hybrid | windows-fleet-management | WinRM/CIM/WAC/Intune/Arc/Graph | NOT_ASSESSED |

The crosswalk copies the Linux engine's evidence and recovery discipline, not
its command names or taxonomy. Windows-only capabilities include AD DS, GPO,
Kerberos, RSAT, Security Compliance Toolkit, Defender, BitLocker, LAPS, IIS,
Hyper-V, Windows Admin Center, Intune, Entra, and Arc.
