# Windows Administration Skills Engine

The Windows Administration Skills Engine governs work on Windows workstations, Windows Server, Active Directory and hybrid fleets, with safety as the first rule. Its 20 skills cover inventory and health, identity and Active Directory, Group Policy and security posture, networking and remote management, patching and servicing, storage, files, services and IIS, Hyper-V and development workstations, backup and recovery, fleet and hybrid management planes (Intune, Entra, Azure Arc, Windows Admin Center), cross-component troubleshooting, and desktop end-to-end testing. The hub skill, `windows-sysadmin`, routes each request to the narrowest specialist listed in `engine/catalog.yaml`. Every operation starts with target and management-owner resolution and is placed in a risk class from R0 (read-only discovery) to R5 (destructive or hard to reverse). Mutations must use preview (`-WhatIf`/`ShouldProcess`) and capture state before and after. They also need explicit authority, per-target outcomes, verification and a recovery path. Missing lab or live evidence is recorded as `NOT_ASSESSED`, never inferred.

The engine produces operational plans and runbooks; routed PowerShell procedures; 48 `wsa-` direct commands under `commands/`; the `WindowsSkills.Engine` PowerShell module that enforces the safety and evidence boundary; and a Python `windows-admin` CLI that lists and routes the catalogue and validates operation files and evidence packs. It also produces redacted evidence records checked against JSON Schema 2020-12 definitions, pywinauto and UI Automation test suites for native desktop applications, and the Windows portability doctrine that the whole Chwezi estate follows for installers and hooks. Volatile platform claims must rest on current official Microsoft documentation, registered as tier-1 sources in `engine/source-register.yaml` with a 90-day review interval. Security baselines follow the Microsoft Security Compliance Toolkit; CIS, STIG and NIST crosswalks are planned only where they are legally licensed. The engine is for Windows system and identity administrators, endpoint and fleet managers, service operators, and the AI agents and other Chwezi engines that need a Windows-native procedure.

## Installation

**Prerequisites.** Git. Node.js 18 or later for the clone installers and the plugin hooks. Python 3.10 or later for the catalogue CLI and validators, or Python 3.11 or later for the Codex model-policy helper. Windows PowerShell 5.1 or PowerShell 7 for the `WindowsSkills.Engine` module and `wsa-` commands. Pester is optional; when it is absent, record its gate as `NOT_ASSESSED`.

**Claude Code plugin (recommended).** The repository is its own marketplace (`.claude-plugin/marketplace.json`, marketplace `chwezi-windows-admin`, plugin `windows-admin`, version 1.1.0):

```text
/plugin marketplace add https://github.com/peterbamuhigire/windows-admin-engine-skills
/plugin install windows-admin@chwezi-windows-admin
```

**Clone installer.** `install.sh` and `install.ps1` delegate to `scripts/install-engine.js`. Scope is `user` (`~/.claude`, the default) or `project` (`.claude` under the current directory). Add `--dry-run` to preview.

```sh
git clone https://github.com/peterbamuhigire/windows-admin-engine-skills
cd windows-admin-engine-skills
./install.sh --scope project        # macOS, Linux or Git Bash
.\install.ps1 --scope project       # Windows PowerShell
```

**Direct command tree.** Put the `wsa-` commands on the user PATH. Preview first: the installer reports every directory, name collision and proposed PATH change, and refuses a collision or an over-long user PATH. `scripts/uninstall-windows-admin.ps1` reverses it.

```powershell
.\scripts\install-windows-admin.ps1 -WhatIf
.\scripts\install-windows-admin.ps1
wsa-list
wsa-route "domain controller replication is failing"
```

**Catalogue CLI.** Run it without installing through `scripts\windows-admin.cmd`, which accepts `list`, `route`, `validate-operation`, `validate-evidence` and `doctor`. `pip install .` also installs it as the `windows-admin` console script.

**Codex.** No installer is needed. Load `AGENTS.md` and `skills/windows-sysadmin/SKILL.md`, then route by `engine/catalog.yaml`. Before substantive work, check the Codex model policy with `python .codex/ensure_model_policy.py --runtime codex --check`. Claude skips this step.

**Manual use.** Clone the repository anywhere. Read `CLAUDE.md` (Claude Code) or `AGENTS.md` (any runner), then `skills/windows-sysadmin/SKILL.md`. Run the quality gates from the repository root:

```powershell
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py
python -X utf8 -m unittest discover -s tests/python -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

## Capabilities

The engine has 20 active `SKILL.md` files in 12 category folders under `skills/`. The authoring template in `templates/skill/` is excluded.

| Category | Skill | What it does |
|---|---|---|
| **Backup, recovery and business continuity (1)** | `windows-backup-recovery` | Assesses protection and plans file, volume, system-state, bare-metal, VM, AD or configuration restore tests. |
| **Fleet, hybrid and management planes (1)** | `windows-fleet-management` | Plans bounded multi-host and canary work across Intune, Entra, Arc, WAC, WinRM and CIM. |
| **Identity, Active Directory and access (2)** | `windows-active-directory-health` | Assesses AD DS forest, domain, DC, DNS, time, replication, trust, FSMO, Kerberos and LDAP health. |
| | `windows-identity-lifecycle` | Plans gated local or AD user, group, computer, gMSA, SPN, LAPS, join and offboarding work. |
| **Inventory, health and diagnostics (2)** | `windows-health-assessment` | Assesses role-aware health, capacity, pending reboot, services, updates, errors and certificates. |
| | `windows-system-inventory` | Collects a read-only host fingerprint, role, runtime, software, service and drift baseline. |
| **Networking and remote management (2)** | `windows-network-admin` | Diagnoses and plans IP, route, DNS, firewall, proxy, VPN, port and name-resolution work. |
| | `windows-remote-management` | Diagnoses WinRM, CIM, PowerShell remoting, SSH, RDP, authentication, delegation and constrained endpoints. |
| **Observability, performance and troubleshooting (1)** | `windows-troubleshooting` | Investigates unexplained symptoms across processes, services, events, boot, crashes, hangs and performance. |
| **Patching, software and endpoint management (1)** | `windows-patch-management` | Plans updates, servicing, patch rings, maintenance windows, failure handling and reboot readiness. |
| **Policy, security and compliance (2)** | `windows-group-policy` | Analyses GPO ownership, scope, precedence, filtering, results, backup, staged change and rollback. |
| | `windows-security-analysis` | Produces a read-only security posture, effective-control, drift and baseline assessment. |
| **Storage, files, services and web (2)** | `windows-iis` | Inventories and diagnoses IIS sites, app pools, bindings, certificates, HTTP.sys, logs and rollback. |
| | `windows-storage-files-services` | Diagnoses disks, volumes, NTFS/ReFS, SMB/DFS, ACLs, VSS, services and scheduled tasks. |
| **Virtualisation, containers and development (3)** | `windows-desktop-e2e-testing` | Sets up end-to-end tests for WPF, WinForms, Win32/MFC or Qt apps with pywinauto and UI Automation. |
| | `windows-development-workstation` | Plans a repeatable developer workstation: PowerShell, Python, Git, SDKs, WSL, certificates, test VMs. |
| | `windows-hyper-v` | Inventories and diagnoses Hyper-V hosts, switches, VMs, checkpoints, replication and Windows containers. |
| **Hub (1)** | `windows-sysadmin` | Routes a Windows request to the right specialist across every category. |
| **Meta (2)** | `windows-kaizen-engine-and-product-improvement` | Audits and improves this engine and the Windows products it produces. |
| | `windows-portability-doctrine` | Governs Windows behaviour of "cross-platform" tooling: Git Bash paths, symlinks, background processes, line endings. |
| **Total** | **20** | |

## References

Citations only. No book text or source conversion is stored in this repository (see `AGENTS.md`, "Never store book extractions"). The live register is `engine/source-register.yaml`.

### Books

- Allen, R. and Lowe-Norris, A. G. (2003) *Active Directory*, 2nd edn. O'Reilly Media. Historical AD concepts only.
- Berkouwer, S. (2022) *Active Directory Administration Cookbook*, 2nd edn. Packt. Every command verified before use.
- Dent, C. (2024) *Mastering PowerShell Scripting*, 5th edn. Packt.
- Hunter, L. E. and Allen, R. *Active Directory Cookbook*, 3rd edn. O'Reilly Media. Historical recipe taxonomy only.
- Jones, D. and Hicks, J. (2017) *The PowerShell Scripting and Toolmaking Book*.
- Krause, J. (2018) *Mastering Windows Group Policy*. Packt.
- Parlow, N. (2024) *PowerShell 7 Workshop*. Packt.
- Petty, J., Jones, D. and Hicks, J. (2022) *Learn PowerShell Scripting in a Month of Lunches*, 2nd edn, MEAP V04. Partial edition.
- Russinovich, M. and Margosis, A. (2016) *Troubleshooting with the Windows Sysinternals Tools*. Microsoft Press.
- Russinovich, M. and Solomon, D. (2005) *Microsoft Windows Internals*, 4th edn. Microsoft Press. Historical concepts only.

### Repositories

- PacktPublishing, *Active Directory Administration Cookbook, Second Edition* code repository: https://github.com/PacktPublishing/Active-Directory-Administration-Cookbook-Second-Edition. Used as a recipe inventory and a negative-engineering corpus; no script was imported or executed (`docs/research/source-synthesis.md`).
- Everything Claude Code (ECC): https://github.com/affaan-m/ECC. `windows-desktop-e2e-testing` is adapted from ECC's `skills/windows-desktop-e2e` (the pywinauto/UIA pattern set and a WPF worked example). `windows-portability-doctrine` is original synthesis that cites ECC's `install.sh`, the `continuous-learning-v2` skill and `TROUBLESHOOTING.md` as incident evidence. `docs/agent-runtime-safety.md` draws on ECC's shortform, longform and security guides.
- DietrichGebert/ponytail: https://github.com/DietrichGebert/ponytail (MIT). The `CLAUDE.md` → `@AGENTS.md` host-file bridge and single-source drift check (PT-01, PT-02, my-10-kaizen M10-02, commit `b1100c5`).
- pbakaus/impeccable: https://github.com/pbakaus/impeccable (Apache-2.0). The `PROJECT.md` (`project_schema: 1`) read rule (IM-11, M10-12, commit `243221f`) and the "Impeccable-derived AS overlay" quality gate in `AGENTS.md`.
- donvito/codex-astra-luna-orchestrator: https://github.com/donvito/codex-astra-luna-orchestrator. A concept reference for the `.codex/` model-policy helper, implemented independently.

### Standards and official sources

- JSON Schema draft 2020-12 (`engine/catalog.schema.json`, `engine/schemas/`): https://json-schema.org/draft/2020-12/schema
- Microsoft Security Compliance Toolkit (versioned security baselines): https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10
- Microsoft Learn, tier-1 entries in `engine/source-register.yaml` (accessed 2026-08-12 unless noted):
  - Windows Server management overview: https://learn.microsoft.com/en-us/windows-server/administration/overview
  - PowerShell documentation: https://learn.microsoft.com/en-us/powershell/
  - PowerShell remoting: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/running-remote-commands
  - Just Enough Administration: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/overview (and prerequisites)
  - Active Directory Domain Services overview: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview
  - Dcdiag: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dcdiag
  - AD replication error 1722: https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/replication-error-1722-rpc-server-unavailable
  - AD forest recovery guide: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-guide
  - Windows LAPS: https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview
  - Group Policy overview: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview
  - Windows Sysinternals: https://learn.microsoft.com/en-us/sysinternals/
  - Windows Admin Center: https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview
  - Get-WinEvent: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent
  - NetTCPIP module: https://learn.microsoft.com/en-us/powershell/module/nettcpip/
  - Windows Remote Management: https://learn.microsoft.com/en-us/windows/win32/winrm/portal
  - Microsoft Defender Antivirus: https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows
  - BitLocker: https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/
  - Windows Update: https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-overview
  - Windows Package Manager (WinGet): https://learn.microsoft.com/en-us/windows/package-manager/winget/
  - Windows Server storage: https://learn.microsoft.com/en-us/windows-server/storage/storage
  - SMB file sharing: https://learn.microsoft.com/en-us/windows-server/storage/file-server/file-server-smb-overview
  - Volume Shadow Copy Service: https://learn.microsoft.com/en-us/windows-server/storage/file-server/volume-shadow-copy-service
  - Windows Server Backup command reference: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-server-backup-command-reference
  - Windows services: https://learn.microsoft.com/en-us/windows/win32/services/services
  - IIS architecture: https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/introduction-to-iis-architecture
  - HTTP Server API (HTTP.sys): https://learn.microsoft.com/en-us/windows/win32/http/http-api-start-page
  - Hyper-V: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-overview
  - Windows containers: https://learn.microsoft.com/en-us/virtualization/windowscontainers/about/
  - Windows Subsystem for Linux: https://learn.microsoft.com/en-us/windows/wsl/about
  - Windows Performance Recorder: https://learn.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-recorder
  - Windows debugger: https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/
  - Azure Arc-enabled servers: https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview
  - Microsoft Intune: https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune
  - Microsoft Graph: https://learn.microsoft.com/en-us/graph/overview
  - Job Objects (accessed 2026-09-24): https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects
  - UI Automation (accessed 2026-09-24): https://learn.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32
  - Environment variables (accessed 2026-09-27): https://learn.microsoft.com/windows/win32/procthread/environment-variables
  - PowerShell DSC 3.0: https://learn.microsoft.com/en-us/powershell/dsc/overview
  - PSScriptAnalyzer: https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview
- CIS, DISA STIG and NIST mappings: named in `docs/plans/windows-engine/` as future crosswalks, "where legally licensed". They are not yet encoded.

### Websites and articles

- Pester: https://pester.dev/
- Accessibility Insights for Windows (Microsoft), named in `windows-desktop-e2e-testing`.
- pytest cache documentation: https://docs.pytest.org/en/stable/how-to/cache.html
- OpenAI image-generation and image-prompting guides, cited by `docs/ai-prompting/domain-prompt-compilation-contract.md`: https://developers.openai.com/api/docs/guides/image-generation and https://developers.openai.com/api/docs/guides/image-prompting
- Windows Administration Skills Engine repository: https://github.com/peterbamuhigire/windows-admin-engine-skills
