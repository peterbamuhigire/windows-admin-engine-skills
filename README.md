# Windows Administration Skills Engine

The Windows Administration Skills Engine governs work on Windows workstations, Windows Server, Active Directory and hybrid fleets, with safety as the first rule. Its 20 skills cover inventory and health, identity and Active Directory, Group Policy and security posture, networking and remote management, patching and servicing, storage, files, services and IIS, Hyper-V and development workstations, backup and recovery, fleet and hybrid management planes (Intune, Entra, Azure Arc, Windows Admin Center), cross-component troubleshooting, and desktop end-to-end testing. The hub skill, `windows-sysadmin`, routes each request to the narrowest specialist listed in `engine/catalog.yaml`. Every operation starts with target and management-owner resolution and is placed in a risk class from R0 (read-only discovery) to R5 (destructive or hard to reverse). Mutations must use preview (`-WhatIf`/`ShouldProcess`) and capture state before and after. They also need explicit authority, per-target outcomes, verification and a recovery path. Missing lab or live evidence is recorded as `NOT_ASSESSED`, never inferred.

The engine produces operational plans and runbooks; routed PowerShell procedures; 48 `wsa-` direct commands under `commands/`; the `WindowsSkills.Engine` PowerShell module that enforces the safety and evidence boundary; and a Python `windows-admin` CLI that lists and routes the catalogue and validates operation files and evidence packs. It also produces redacted evidence records checked against JSON Schema 2020-12 definitions, pywinauto and UI Automation test suites for native desktop applications, and the Windows portability doctrine that the whole Chwezi estate follows for installers and hooks. Volatile platform claims must rest on current official Microsoft documentation, registered as tier-1 sources in `engine/source-register.yaml` with a 90-day review interval. Security baselines follow the Microsoft Security Compliance Toolkit; CIS, STIG and NIST crosswalks are planned only where they are legally licensed. The engine is for Windows system and identity administrators, endpoint and fleet managers, service operators, and the AI agents and other Chwezi engines that need a Windows-native procedure.

## Quality and improvement

The evidence is in two folders: [29 October 2026](docs/kaizen/2026-10-engine-kaizen/05-final-report.md) and [pass 2, 31 October 2026](docs/kaizen/2026-10-engine-kaizen-pass-2/05-final-report.md). Each holds the scope, baseline scorecard, backlog, experiment log, validation record, final report and next-cycle list. The router (`AGENTS.md`) points agents at both.

**Latest published score: 59.5.** The pass-2 raw score is 59.5 and the published score is `min(raw, 65)`, which is also 59.5. The fresh baseline for that pass was 56.7 raw, and the 29 October final was 57.9 raw. The scores are reviewer judgements over ten equally weighted dimensions. The target of 95 is not met.

Pass 2 improved the parts that Python can check: the fleet-manifest validator, link and path scans, a source-register date gate, and routing fixtures. No PowerShell ran in that pass, and no Windows host, domain, tenant or fleet was touched. Synthetic Linux-hosted PowerShell tests do not establish Windows fleet readiness.

**`scripts/validate_fleet_manifest.py` refuses manifests that the validator before pass 2 accepted.** Run today against the 17 fixtures in `tests/fixtures/fleet-manifest/`, the current validator exits 1 on the 16 refused manifests and 0 on the accepted one. The version at `8d6faea` exited 0 on nine of those 16: a revoked authority; an R4 or R5 target whose approved authority has the same owner and approver; a change or maintenance window written as free text; an inverted change window; a maintenance window outside the change window; and a wildcard, list or CIDR hostname. Both versions refuse an expired manifest, a duplicate host, a missing authority, a blank approver, empty targets, more targets than `max_hosts`, and an unknown risk tier. The validator reads one file and contacts no host. Its output states that approval authenticity and fleet readiness are `NOT_ASSESSED`.

**Open findings that matter to a user** (full list: [next-cycle file](docs/kaizen/2026-10-engine-kaizen-pass-2/06-next-cycle.md)):

- `Invoke-WseServiceState` takes `-ChangeAuthority` and `-MaintenanceWindow` as text and does not evaluate either. This is a static finding from reading the source. Treat the window and the authority as the operator's responsibility.
- No Windows integration exists for service state, Group Policy, AD or SMB, and no fleet window, canary or timed restore has run. R3 to R5 work stays blocked until recovery proof exists.
- The fleet manifest has no canary field, although `windows-fleet-management` requires a canary.
- `wsa-dns-test` and `wsa-port-test` query or connect to whatever name or host the operator types. Neither is bound to a fleet manifest, although `docs/safety-model.md` says only manifest targets may be contacted. Both are read-only probes.
- PowerShell fixtures last ran on 7.4.2 (support ends 2026-11-10). They have not run on 7.6 LTS or on Windows PowerShell 5.1.
- `windows-admin doctor` and `engine/catalog.yaml` report engine version `0.1.0`; the plugin and engine manifests say `1.1.0`.

**Calendar of date-triggered gates.** `scripts/check_source_register.py` fails on a date, by design, unless the register is re-verified from primary sources. Each row below was measured with `--as-of`, which evaluates the register at a chosen day.

| Date | Result of `check_source_register.py --as-of <date>` | Cause |
|---|---|---|
| 2026-11-05 | exit 0, 0 findings (last green day) | `policy.scoped_october_review_date` is 2026-11-05; the pass-2 re-audit is due the same day |
| 2026-11-06 | exit 1, 1 finding | that policy review date has passed |
| 2026-11-11 | exit 1, 39 findings | 35 URL rows past the 90-day interval (last dated 2026-08-12), three `review_by` rows dated 2026-11-10 (PowerShell lifecycle, Windows 11 release, Windows Server release) and the policy date |
| 2026-12-01 | exit 1, 43 findings | four rows with `review_by` 2026-11-30: `MS-SCT`, `MS-ARC-AGENT-RELEASE`, `MS-INTUNE-WHATS-NEW`, `MS-ENTRA-WHATS-NEW` |
| 2026-12-24 | exit 1, 45 findings | `MS-JOB-OBJECTS` and `MS-UIA`, last dated 2026-09-24, pass 90 days |
| 2027-01-30 | exit 1, 54 findings | nine rows verified on 2026-10-31 pass 90 days |
| 2027-02-01 | exit 1, 56 findings | `MS-IIS-LIFECYCLE` and `MS-HYPERV-OVERVIEW` pass their `review_by` of 2027-01-31 |

On 2026-11-10 the check still reports only the policy finding, but the 35 rows have reached the end of their interval; PowerShell 7.4 and 7.5 support and Windows 11 23H2 Enterprise servicing also end that day. Two further review dates are read by no validator: the six architecture decisions and the threat model fall due on 2026-11-12. To clear the gate, re-read each row's source, set `verified` on rows actually read, move `policy.scoped_october_review_date`, and record the review in `docs/research/`. The scoped reviews so far are [29 October](docs/research/currentness-2026-10-29.md) and [31 October](docs/research/currentness-2026-10-31.md). Two worked plans cover [a Group Policy pilot](docs/operations/group-policy-pilot.md) and [file-share diagnosis after patching](docs/operations/file-share-after-patching.md). The index of every document is [docs/README.md](docs/README.md).

## Installation

**Prerequisites.** Git. Node.js 18 or later for the clone installers and the plugin hooks. Python 3.10 or later for the catalogue CLI and validators, or Python 3.11 or later for the Codex model-policy helper; the Python code uses the standard library only, so there is no requirements file and no PyYAML. Windows PowerShell 5.1 or PowerShell 7 for the `WindowsSkills.Engine` module and `wsa-` commands. `scripts/test-powershell.ps1` requires Pester 5 or later and stops with an error when it is missing; record that gate as `NOT_ASSESSED`, never as a pass.

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

**Catalogue CLI.** It accepts `list`, `route`, `validate-operation`, `validate-evidence` and `doctor`. On Windows, run it without installing through `scripts\windows-admin.cmd`. On Linux or macOS, run it from the repository root with `PYTHONPATH=python python3 -X utf8 -m windows_admin.cli route "domain controller replication is failing"`. `pip install .` also installs it as the `windows-admin` console script.

**Codex.** The existing Claude-compatible marketplace also installs in Codex
without a duplicate skill tree. From a local checkout run `codex plugin marketplace add . --json`,
then `codex plugin add windows-admin@chwezi-windows-admin --json`. Offline native
checks expose all 20 declared skill paths; see [plugin checks](docs/marketplace.md).
Both the package and full checkout have an enforced hard 5,000-file ceiling.
For manual use, no installer is needed. Load `AGENTS.md` and `skills/windows-sysadmin/SKILL.md`, then route by `engine/catalog.yaml`. Before substantive work, check the Codex model policy with `python3 .codex/ensure_model_policy.py --runtime codex --check` (`python` on Windows). It needs Python 3.11 or later and exits 1 when the Codex configuration drifts from the shipped policy. Claude skips this step.

**Manual use.** Clone the repository anywhere. Read `CLAUDE.md` (Claude Code) or `AGENTS.md` (any runner), then `skills/windows-sysadmin/SKILL.md`. The quality gates are listed below.

## Validation

Run each command from the repository root. On Windows, use `python` where this section says `python3`. The Python gates need Python 3.10 or later and nothing else: they use the standard library, and no requirements file exists. `pytest` is optional; `python3 -m pytest -p no:cacheprovider` runs the same test files as `unittest`. Node.js 18 or later runs the hook tests. The PowerShell gates need `pwsh` or Windows PowerShell and, for `scripts/test-powershell.ps1`, Pester 5 or later. No validator needs a sibling engine checkout; the results below were also reproduced from a standalone clone.

**Runs on Linux, macOS and Windows.** Measured on Linux with Python 3.14.8 and Node.js 22 on 2026-10-31. Every row exited 0.

| Command | Result |
|---|---|
| `python3 -X utf8 scripts/validate_engine.py` | 19 specialist skills validated, 0 findings. It also runs the marketplace check (`scripts/check_marketplace.py`, 20 skill paths, 5,000-file ceiling) and the content-hygiene scan (`scripts/check_content_hygiene.py`: Markdown links, `windows-*` skill identifiers and machine-specific paths in every tracked file). |
| `python3 -X utf8 scripts/routing_smoke_test.py` | 73 fixtures, 0 failures; first rank 73/73; owned negatives 23/23; 11 of 19 specialists meet the three-positive, two-negative threshold (floor 11). The oracle is lexical, so this is not a measure of model routing. |
| `python3 -X utf8 scripts/source_ingestion_guardrail.py` | 0 findings. |
| `python3 -X utf8 scripts/check_source_register.py` | 56 rows, 46 URL rows, 0 expired, 35 warnings. Exit 0 today, and date-triggered: see the calendar above. `--as-of YYYY-MM-DD` evaluates another day. It reads dates only and makes no network request. |
| `python3 -X utf8 scripts/validate_command_tree.py` | 48 direct commands, 0 findings. |
| `python3 -X utf8 scripts/validate_operator_manual.py` | 48 commands, 19 scripts, 12 functions named in the manual, 0 findings. |
| `python3 -X utf8 scripts/validate_fleet_manifest.py tests/fixtures/fleet-manifest.valid.json` | 1 target, 0 findings, `contact_attempted=false`. |
| `python3 -X utf8 -m unittest discover -s tests/python -v` | 72 tests, OK. |
| `python3 -X utf8 -m unittest tests/test_approval_adapter.py` | 1 test, OK. It sits outside the discovery root above, so the registered command does not run it. `pytest` from the repository root collects 73 tests and all pass. |
| `node hooks/test-destructive-bash-gate.js` | 61 of 61 passed. |
| `node hooks/test-plugin-hook-config.js` | 7 of 7 passed. |

`.skills-engine/engine-manifest.yaml` registers six validators: `validate_engine.py`, `routing_smoke_test.py`, `source_ingestion_guardrail.py`, the unit tests, `check_source_register.py` and, for Windows only, `test-powershell.ps1`. CI (`.github/workflows/ci.yml`) runs those on `windows-latest` with Python 3.12, plus the command-tree, operator-manual and fleet-manifest checks and the PowerShell syntax check and installer preview. CI does not run the hook tests or `tests/test_approval_adapter.py`.

**Needs PowerShell: `NOT_ASSESSED` on the Linux host.** There is no `pwsh` or Windows PowerShell on this machine; running any command below returns `pwsh: command not found` with exit 127. On 29 October 2026, in a PowerShell 7.4.2 Linux container, the syntax check passed over 80 files and the service fixtures ran. `test-powershell.ps1` passed its fixture steps there and then failed on a Windows-only API, so it needs a Windows host. The last recorded Pester run is 2026-08-12 ([test plan](docs/testing/test-plan.md)).

| Command | What it checks |
|---|---|
| `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` | Parses every `.ps1` file (80 are tracked) and fails on a syntax error. |
| `pwsh -NoProfile -File scripts/test-service-state-fixture.ps1` and `scripts/test-service-wrapper-fixture.ps1` | Synthetic fixtures. The state fixture asserts the normal, repeat, preview, refusal, failure and verified-recovery paths (nine assertions); the wrapper fixture makes three isolated calls through the typed wrapper and dispatcher. Neither touches a Windows service. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1` | The two fixtures, module import and doctor, local inventory, a `-WhatIf` service preview, then four Pester suites. Needs Pester 5. |
| `.\scripts\install-windows-admin.ps1 -WhatIf` | Previews the PATH and environment changes of the direct command tree. |

Every `wsa-` command, and every Windows, Active Directory, Group Policy, IIS, Hyper-V, Intune, Entra or Arc behaviour, is also `NOT_ASSESSED` without a Windows host or lab. Static checks do not replace those gates.

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
