# Windows Administration Skills Engine

A set of 20 skills that guide an AI agent or an operator through safe work on Windows workstations, Windows Server, Active Directory and hybrid fleets. A hub skill routes each request to one specialist and gives it a risk class from R0 (read-only discovery) to R5 (destructive or hard to reverse).

Changes are previewed first and need before and after evidence, explicit authority and a recovery path. Missing lab or live evidence is recorded as `NOT_ASSESSED`, never inferred.

**Who it is for:** Windows system and identity administrators, endpoint and fleet managers, service operators, and the AI agents and other Chwezi engines that need a Windows-native procedure. **Use it when** a task touches a Windows host, a domain or a fleet. For Linux hosts use `linux-skills`.

**At a glance** (measured on Linux, 2026-10-31)

- 20 skills (one hub, 19 specialists) in 12 folders, and 48 `wsa-` direct commands.
- 73 routing fixtures, all ranked first by a lexical oracle, and 72 Python unit tests.
- 11 checks run on Linux with `python3` or `node`. All exited 0.
- 4 checks need PowerShell. They are `NOT_ASSESSED` on this Linux host, which has no `pwsh`.
- The source-register check exits 0 until 2026-11-05 and fails from 2026-11-06 unless rows are re-verified.
- Latest published kaizen score: 59.5. The target of 95 is not met.

## Start here

Steps 2 and 3 need only Python 3.10 or later, run on Linux, macOS or Windows (use `python` for `python3` on Windows) and contact no Windows host. The PowerShell side (the `wsa-` commands and the module) needs `pwsh` or a Windows host; [Validation](#validation) shows which checks need it.

1. **Get the engine.** Clone it. To install it as a Claude Code plugin instead, see [Install and update](#install-and-update).

   ```sh
   git clone https://github.com/peterbamuhigire/windows-admin-engine-skills
   cd windows-admin-engine-skills
   ```

2. **Check it.** The validator prints `findings=0` when the 19 specialist skills, the marketplace layout and the content scans pass.

   ```sh
   python3 -X utf8 scripts/validate_engine.py
   ```

3. **Use it.** Route a request. The CLI ranks skills, for example `windows-active-directory-health` at risk class R0. Then read that skill's `SKILL.md` and follow its risk class.

   ```sh
   PYTHONPATH=python python3 -X utf8 -m windows_admin.cli route "domain controller replication is failing"
   ```

## Contents

- [Start here](#start-here)
- [When to use it and find the right skill](#when-to-use-it-and-find-the-right-skill)
- [How it works](#how-it-works)
- [What is inside](#what-is-inside)
- [Install and update](#install-and-update)
- [Validation](#validation): what runs on Linux with Python, and what needs PowerShell
- [Quality and improvement](#quality-and-improvement): score, open findings and the calendar of date-triggered gates
- [What the October 2026 kaizen improved](#what-the-october-2026-kaizen-improved)
- [References](#references)
- [Contributing, author and licence](#contributing-author-and-licence)

## When to use it and find the right skill

Use the engine for inventory and health, identity and Active Directory, Group Policy and security posture, networking and remote management, patching, storage and IIS, Hyper-V, backup and recovery, fleet and hybrid management, troubleshooting, and desktop testing.

| Task | Skill | Highest risk class |
|---|---|---|
| Inventory a Windows laptop or server | `windows-system-inventory` | R0 |
| Check AD replication and domain controller health | `windows-active-directory-health` | R0 |
| Offboard a domain user and remove privileged group membership | `windows-identity-lifecycle` | R4 |
| Show resultant set of policy and GPO precedence | `windows-group-policy` | R4 |
| Assess Defender, BitLocker and baseline drift | `windows-security-analysis` | R0 |
| Plan a patch ring and a reboot window | `windows-patch-management` | R2 |
| Diagnose an SMB share ACL and a stopped service | `windows-storage-files-services` | R2 |
| Diagnose an IIS app pool that returns 503 after a certificate binding change | `windows-iis` | R2 |
| Prove the system state backup can meet the RTO | `windows-backup-recovery` | R5 |
| Apply a change to all machines through Intune canary rings | `windows-fleet-management` | R4 |
| Investigate a machine that hangs with high CPU and no known cause | `windows-troubleshooting` | R0 |
| Diagnose WinRM authentication that fails with a workgroup machine | `windows-remote-management` | R3 |

The tasks follow the routing fixtures in `tests/fixtures/routing.json`, and the catalogue CLI ranks the named skill first for each fixture wording. The risk class is the highest one the skill covers, from `engine/catalog.yaml`.

If no row fits, ask the hub skill `windows-sysadmin`, or glob `skills/**/SKILL.md` and route by each frontmatter `description`. [What is inside](#what-is-inside) lists all 20.

## How it works

1. The hub skill `windows-sysadmin` routes the request to the narrowest specialist listed in `engine/catalog.yaml`.
2. The specialist resolves the target and the management owner (local, Group Policy, MDM, DSC, Configuration Manager, Arc or vendor) before anything changes.
3. The operation gets a risk class from R0 to R5. [AGENTS.md](AGENTS.md) holds the table.
4. A mutation needs a preview (`-WhatIf` or `ShouldProcess`), before and after state, explicit authority, per-target outcomes, verification and a recovery path.
5. Anything not proved on a real host or lab is `NOT_ASSESSED`. A zero exit code is not outcome verification.

**What the engine produces**

- Operational plans and runbooks, and routed PowerShell procedures.
- 48 `wsa-` direct commands under `commands/`.
- The `WindowsSkills.Engine` PowerShell module, which enforces the safety and evidence boundary.
- A Python `windows-admin` CLI that lists and routes the catalogue and validates operation files and evidence packs.
- Redacted evidence records checked against JSON Schema 2020-12 definitions.
- pywinauto and UI Automation test suites for native desktop applications.
- The Windows portability doctrine that the whole Chwezi estate follows for installers and hooks.

**Currency**

- Volatile platform claims must rest on current official Microsoft documentation, registered as tier-1 sources in `engine/source-register.yaml` with a 90-day review interval.
- Security baselines follow the Microsoft Security Compliance Toolkit. CIS, STIG and NIST crosswalks are planned only where they are legally licensed.

## What is inside

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

Other top-level folders:

- `engine/`: the catalogue, its schemas, the platform matrix and the source register.
- `commands/`, `powershell/` and `python/`: the `wsa-` command tree, the `WindowsSkills.Engine` module and the `windows-admin` CLI.
- `scripts/`: validators and installers. `hooks/`: the Claude Code hooks, including the destructive-command gate.
- `tests/`, `templates/`, `rules/` and `labs/`: tests and fixtures; change-plan, rollback-plan, evidence-pack and skill templates; always-on rules; and the disposable-lab definitions.
- `docs/`: the [document index](docs/README.md).

## Install and update

**Prerequisites**

- Git.
- Node.js 18 or later, for the clone installers and the plugin hooks.
- Python 3.10 or later, for the catalogue CLI and validators. The Codex model-policy helper needs Python 3.11 or later. The Python code uses only the standard library, so there is no requirements file and no PyYAML.
- Windows PowerShell 5.1 or PowerShell 7, for the `WindowsSkills.Engine` module and the `wsa-` commands.
- Pester 5 or later, for `scripts/test-powershell.ps1`. The script stops with an error when Pester is missing; record that gate as `NOT_ASSESSED`, never as a pass.

**Claude Code plugin (recommended).** The repository is its own marketplace (`.claude-plugin/marketplace.json`, marketplace `chwezi-windows-admin`, plugin `windows-admin`, version 1.1.0):

```text
/plugin marketplace add https://github.com/peterbamuhigire/windows-admin-engine-skills
/plugin install windows-admin@chwezi-windows-admin
```

**Clone installer.** `install.sh` and `install.ps1` delegate to `scripts/install-engine.js`. Clone the repository first (see [Start here](#start-here)). Scope is `user` (`~/.claude`, the default) or `project` (`.claude` under the current directory). Add `--dry-run` to preview.

```sh
./install.sh --scope project        # macOS, Linux or Git Bash
.\install.ps1 --scope project       # Windows PowerShell
```

**Direct command tree.** This puts the `wsa-` commands on the user PATH. Preview first: the installer reports every directory, name collision and proposed PATH change, and refuses a collision or an over-long user PATH.

```powershell
.\scripts\install-windows-admin.ps1 -WhatIf
.\scripts\install-windows-admin.ps1
wsa-list
wsa-route "domain controller replication is failing"
```

After a `git pull`, run the installer again. It reconciles stale paths, and a repeat run with nothing to change reports `Mode=NoChange` ([evidence](docs/release/idempotent-installer-2026-08-12.md)). `scripts/uninstall-windows-admin.ps1` reverses it.

**Catalogue CLI.** It accepts `list`, `route`, `validate-operation`, `validate-evidence` and `doctor`. `pip install .` also installs it as the `windows-admin` console script.

- On Windows, run it without installing through `scripts\windows-admin.cmd`.
- On Linux or macOS, run it from the repository root with `PYTHONPATH=python python3 -X utf8 -m windows_admin.cli route "domain controller replication is failing"`.

**Codex.** The Claude-compatible marketplace also installs in Codex without a duplicate skill tree.

- From a local checkout run `codex plugin marketplace add . --json`, then `codex plugin add windows-admin@chwezi-windows-admin --json`.
- Offline native checks expose all 20 declared skill paths (see [plugin checks](docs/marketplace.md)). The package and the full checkout both have an enforced hard 5,000-file ceiling.
- Before substantive work, check the Codex model policy with `python3 .codex/ensure_model_policy.py --runtime codex --check` (`python` on Windows).
- The check needs Python 3.11 or later and exits 1 when the Codex configuration drifts from the shipped policy. Claude skips this step.

**Manual use.** No installer is needed. Read `CLAUDE.md` (Claude Code) or `AGENTS.md` (any runner), then `skills/windows-sysadmin/SKILL.md`, and route by `engine/catalog.yaml`. [Validation](#validation) lists the quality gates.

## Validation

Run each command from the repository root. On Windows, use `python` where this section says `python3`. The checks fall into two groups:

- **Python and Node.js checks** run on Linux, macOS and Windows. They use the standard library only, and no requirements file exists. Node.js 18 or later runs the hook tests.
- **PowerShell checks** need `pwsh` or Windows PowerShell, and Pester 5 or later for `scripts/test-powershell.ps1`. They are `NOT_ASSESSED` on a host without PowerShell.

`pytest` is optional: `python3 -m pytest -p no:cacheprovider` runs the same test files as `unittest`. No validator needs a sibling engine checkout; the results below were also reproduced from a standalone clone.

### Runs on Linux, macOS and Windows

Measured on Linux with Python 3.14.8 and Node.js 22 on 2026-10-31. Every row exited 0.

| Command | Result |
|---|---|
| `python3 -X utf8 scripts/validate_engine.py` | 19 specialist skills validated, 0 findings. It also runs the marketplace check (`check_marketplace.py`: 20 skill paths, 5,000-file ceiling) and the content-hygiene scan (`check_content_hygiene.py`: links, `windows-*` identifiers, machine paths). |
| `python3 -X utf8 scripts/routing_smoke_test.py` | 73 fixtures, 0 failures; first rank 73/73; owned negatives 23/23; 11 of 19 specialists meet the three-positive, two-negative threshold (floor 11). The oracle is lexical, so this does not measure model routing. |
| `python3 -X utf8 scripts/source_ingestion_guardrail.py` | 0 findings. |
| `python3 -X utf8 scripts/check_source_register.py` | 56 rows, 46 URL rows, 0 expired, 35 warnings. Exit 0 on 2026-10-31, and date-triggered (see the [calendar](#calendar-of-date-triggered-gates)). `--as-of YYYY-MM-DD` evaluates another day. It reads dates only and makes no network request. |
| `python3 -X utf8 scripts/validate_command_tree.py` | 48 direct commands, 0 findings. |
| `python3 -X utf8 scripts/validate_operator_manual.py` | 48 commands, 19 scripts, 12 functions named in the manual, 0 findings. |
| `python3 -X utf8 scripts/validate_fleet_manifest.py tests/fixtures/fleet-manifest.valid.json` | 1 target, 0 findings, `contact_attempted=false`. |
| `python3 -X utf8 -m unittest discover -s tests/python -v` | 72 tests, OK. |
| `python3 -X utf8 -m unittest tests/test_approval_adapter.py` | 1 test, OK. It sits outside the discovery root above, so the registered command skips it. `pytest` from the repository root collects 73 tests, and all pass. |
| `node hooks/test-destructive-bash-gate.js` | 61 of 61 passed. |
| `node hooks/test-plugin-hook-config.js` | 7 of 7 passed. |

**Registered validators and CI**

- `.skills-engine/engine-manifest.yaml` registers six: `validate_engine.py`, `routing_smoke_test.py`, `source_ingestion_guardrail.py`, the unit tests, `check_source_register.py` and, for Windows only, `test-powershell.ps1`.
- CI (`.github/workflows/ci.yml`) runs those on `windows-latest` with Python 3.12. It adds the command-tree, operator-manual and fleet-manifest checks, the PowerShell syntax check and the installer preview.
- CI does not run the hook tests or `tests/test_approval_adapter.py`.

### Needs PowerShell: `NOT_ASSESSED` on the Linux host

There is no `pwsh` or Windows PowerShell on this machine. Running any command below returns `pwsh: command not found` with exit 127.

On 29 October 2026, in a PowerShell 7.4.2 Linux container, the syntax check passed over 80 files and the service fixtures ran.

`test-powershell.ps1` passed its fixture steps there and then failed on a Windows-only API, so it needs a Windows host. The last recorded Pester run is 2026-08-12 ([test plan](docs/testing/test-plan.md)).

| Command | What it checks |
|---|---|
| `pwsh -NoProfile -File scripts/test-powershell-syntax.ps1` | Parses every `.ps1` file (80 are tracked) and fails on a syntax error. |
| `pwsh -NoProfile -File scripts/test-service-state-fixture.ps1` and `scripts/test-service-wrapper-fixture.ps1` | Two synthetic fixtures: nine state assertions and three wrapper calls. Neither touches a Windows service. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1` | The two fixtures, module import and doctor, local inventory, a `-WhatIf` service preview, then four Pester suites. Needs Pester 5. |
| `.\scripts\install-windows-admin.ps1 -WhatIf` | Previews the PATH and environment changes of the direct command tree. |

The state fixture covers the normal, repeat, preview, refusal, failure and verified-recovery paths. The wrapper fixture makes three isolated calls through the typed wrapper and dispatcher.

Every `wsa-` command, and every Windows, Active Directory, Group Policy, IIS, Hyper-V, Intune, Entra or Arc behaviour, is also `NOT_ASSESSED` without a Windows host or lab. Static checks do not replace those gates.

## Quality and improvement

The evidence is in two folders: [29 October 2026](docs/kaizen/2026-10-engine-kaizen/05-final-report.md) and [pass 2, 31 October 2026](docs/kaizen/2026-10-engine-kaizen-pass-2/05-final-report.md).

Each holds the scope, baseline scorecard, backlog, experiment log, validation record, final report and next-cycle list. The router (`AGENTS.md`) points agents at both.

### Score

**Latest published score: 59.5.** The pass-2 raw score is 59.5, and the published score is `min(raw, 65)`, which is also 59.5.

The fresh baseline for that pass was 56.7 raw, and the 29 October final was 57.9 raw. The scores are reviewer judgements over ten equally weighted dimensions. The target of 95 is not met.

Pass 2 improved the parts that Python can check: the fleet-manifest validator, link and path scans, a source-register date gate and routing fixtures. The itemised list is under [What the October 2026 kaizen improved](#what-the-october-2026-kaizen-improved).

No PowerShell ran in that pass, and no Windows host, domain, tenant or fleet was touched. Synthetic Linux-hosted PowerShell tests do not establish Windows fleet readiness.

### Fleet-manifest validator

`scripts/validate_fleet_manifest.py` refuses manifests that the validator before pass 2 accepted. Run on 2026-10-31 against the 17 fixtures in `tests/fixtures/fleet-manifest/`, it exits 1 on the 16 refused manifests and 0 on the accepted one.

- The version at `8d6faea` exited 0 on nine of those 16. The cases were:
  - a revoked authority;
  - an R4 or R5 target whose approved authority has the same owner and approver;
  - a change or maintenance window written as free text;
  - an inverted change window;
  - a maintenance window outside the change window;
  - a wildcard, list or CIDR hostname.
- Both versions refuse an expired manifest, a duplicate host, a missing authority, a blank approver, empty targets, more targets than `max_hosts`, and an unknown risk tier.
- The validator reads one file and contacts no host. Its output states that approval authenticity and fleet readiness are `NOT_ASSESSED`.

### Open findings that matter to a user

The full list is in the [next-cycle file](docs/kaizen/2026-10-engine-kaizen-pass-2/06-next-cycle.md).

- `Invoke-WseServiceState` takes `-ChangeAuthority` and `-MaintenanceWindow` as text and evaluates neither. This is a static finding from reading the source. Treat the window and the authority as the operator's responsibility.
- No Windows integration exists for service state, Group Policy, AD or SMB, and no fleet window, canary or timed restore has run. R3 to R5 work stays blocked until recovery proof exists.
- The fleet manifest has no canary field, although `windows-fleet-management` requires a canary.
- `wsa-dns-test` and `wsa-port-test` query or connect to whatever name or host the operator types. Neither is bound to a fleet manifest, although `docs/safety-model.md` says only manifest targets may be contacted. Both are read-only probes.
- PowerShell fixtures last ran on 7.4.2 (support ends 2026-11-10). They have not run on 7.6 LTS or on Windows PowerShell 5.1.
- `windows-admin doctor` and `engine/catalog.yaml` report engine version `0.1.0`; the plugin and engine manifests say `1.1.0`.

### Calendar of date-triggered gates

`scripts/check_source_register.py` fails on a date, by design, unless the register is re-verified from primary sources. **The first red day is 2026-11-06.** Each row below was measured with `--as-of`, which evaluates the register on a chosen day. On 2026-10-31 the check exited 0 with 35 warnings.

| Date | Result of `check_source_register.py --as-of <date>` | Cause |
|---|---|---|
| 2026-11-05 | exit 0, 0 findings (last green day) | `policy.scoped_october_review_date` is 2026-11-05; the pass-2 re-audit is due the same day |
| 2026-11-06 | exit 1, 1 finding | that policy review date has passed |
| 2026-11-10 | exit 1, 1 finding | still only the policy finding; the 35 URL rows reach the end of their interval that day |
| 2026-11-11 | exit 1, 39 findings | 35 URL rows past the 90-day interval (last dated 2026-08-12), three `review_by` rows dated 2026-11-10 (PowerShell lifecycle, Windows 11 release, Windows Server release) and the policy date |
| 2026-12-01 | exit 1, 43 findings | four rows with `review_by` 2026-11-30: `MS-SCT`, `MS-ARC-AGENT-RELEASE`, `MS-INTUNE-WHATS-NEW`, `MS-ENTRA-WHATS-NEW` |
| 2026-12-24 | exit 1, 45 findings | `MS-JOB-OBJECTS` and `MS-UIA`, last dated 2026-09-24, pass 90 days |
| 2027-01-30 | exit 1, 54 findings | nine rows verified on 2026-10-31 pass 90 days |
| 2027-02-01 | exit 1, 56 findings | `MS-IIS-LIFECYCLE` and `MS-HYPERV-OVERVIEW` pass their `review_by` of 2027-01-31 |

- PowerShell 7.4 and 7.5 support and Windows 11 23H2 Enterprise servicing also end on 2026-11-10.
- Two further review dates are read by no validator: the six architecture decisions and the threat model fall due on 2026-11-12.
- To clear the gate, re-read each row's source, set `verified` on rows actually read, move `policy.scoped_october_review_date`, and record the review in `docs/research/`.
- The scoped reviews so far are [29 October](docs/research/currentness-2026-10-29.md) and [31 October](docs/research/currentness-2026-10-31.md).
- Two worked plans cover [a Group Policy pilot](docs/operations/group-policy-pilot.md) and [file-share diagnosis after patching](docs/operations/file-share-after-patching.md).
- The index of every document is [docs/README.md](docs/README.md).

## What the October 2026 kaizen improved

Two cycles ran: 29 October (items W1 to W5, measured from `52a2cdc`) and 31 October, pass 2 (K1 to K7, measured from `8d6faea`). Only kept changes are listed, and both final reports record that no experiment was reverted.

- Every commit hash below was confirmed with `git show --stat` and `git merge-base --is-ancestor <hash> main`.
- Figures marked "re-measured" were produced on 2026-10-31 on Linux with Python 3.14.8. Figures marked "evidence" are copied from the named record.
- Nothing that needs PowerShell ran on this host (`pwsh: command not found`, exit 127), and no Windows host, domain, tenant or fleet was touched in either cycle.

The full wording of each item, with the method behind each figure, is in [the itemised list](docs/kaizen/october-2026-improvements.md).

Evidence: the [29 October final report](docs/kaizen/2026-10-engine-kaizen/05-final-report.md) and the [pass-2 final report](docs/kaizen/2026-10-engine-kaizen-pass-2/05-final-report.md).

| Measure | Before | Now | Basis |
|---|---|---|---|
| Python unit tests | 23 (`52a2cdc`); 31 (`8d6faea`) | 72 | re-measured: `unittest discover -s tests/python` on each export |
| Routing fixtures, all ranked first | 19 of 19; 34 of 34 | 73 of 73 | re-measured with a separate script over `tests/fixtures/routing.json` |
| Owned-negative routing fixtures | 0; 7 | 23 | re-measured |
| Specialists with three positive and two owned-negative fixtures | 0 of 19; 3 of 19 | 11 of 19 | re-measured |
| Refused fleet manifests that the validator accepted (16 fixtures) | 9 of 16 (`8d6faea`) | 0 of 16 | re-measured: the old validator over the 17 fixtures of 2026-10-31 |
| Content defects found by the hygiene check (links, skill names, machine paths) | 12 (export of `8d6faea`) | 0 | re-measured |
| Source-register rows; rows with a `verified` date | 48; 0 | 56; 9 | re-measured by parsing the register |
| Register URLs that answer (liveness, not claim support) | 38 of 38 | 46 of 46 | evidence: both validation records; not re-run |
| Synthetic service fixtures (PowerShell) | 0 scripts | 2 scripts | evidence: nine state assertions, three wrapper calls; the nine was confirmed by reading the script, not by running it |
| Reviewer score, raw / `min(raw, 65)` | 49.3 / 49.3 (`52a2cdc`); 56.7 / 56.7 (`8d6faea`) | 59.5 / 59.5 | evidence: the two final reports. Reviewer judgements, not measurements; the cap does not bind below 65; target 95 not met |

### Safety and correctness fixes, most severe first

- **W1, `9683fd2` (critical): service-state refusal and recovery.** `Invoke-WseServiceState` left no result on an out-of-scope computer name and skipped recovery after a mid-change failure. It now refuses first and restores the original state. A failed restore reports `Recovery=FAILED`.
  - Verified on 29 October by `scripts/test-service-state-fixture.ps1` (nine assertions, PowerShell 7.4.2 container); not re-run here.
- **W2, `141c7b4` (critical): typed service wrapper.** `wsa-service-state` passed `@args` positionally, so named parameters failed binding before any lookup. Parameters now pass by name, `-WhatIf` and `-Confirm` survive, and a Failed result exits non-zero.
  - Verified on 29 October by `scripts/test-service-wrapper-fixture.ps1`; not re-run here.
- **K1, `cd81d03` (critical): the fleet-manifest validator failed open.** Revoked authority, free-text or inverted windows, a wildcard hostname and a self-approved R4 target all passed. Each is now refused (see [Fleet-manifest validator](#fleet-manifest-validator)).
  - Eight single-field mutations of the valid fixture went from 0 findings to 1 each. The pass-2 reports say nine, but their own table lists eight.
- **K2, `83f3e03`: schema and validator disagreed.** The fleet-manifest JSON Schema was read by no code. It now carries the authority object, and `tests/python/test_fleet_manifest_schema.py` fails when the two disagree on a refusal the schema can express.
- **W3, `e8e313e`: diagnosis before repair.** "Domain-joined machines cannot reach a file share after patching" ranked `windows-storage-files-services` first, against the hub rule. Unknown-cause wording now ranks `windows-troubleshooting` first. The oracle is lexical.
- **W4, `b2ddf50`, `cf416fd`: an unintended 21st plugin component.** Native Claude listed `commands/README.md` beside the 20 skills. The text moved to `docs/operations/direct-command-tree.md`, and `scripts/check_marketplace.py` now enforces the skill paths and a 5,000-file ceiling.
- **`29c4958`, `e87ef73`: acceptance-review corrections.** The `TimeoutSeconds` description now says it bounds state polling and cannot cancel a hung call.
  - The 29 October currentness review cites Microsoft's KB5134137 notice, so the narrower scope of that 2026-10-26 Server 2025 out-of-band update is not read as the October B baseline.

### Checks added so these defects cannot return unseen

- **K3, `4ee2587`: skill names and links resolve.** Two worked plans named a skill that is not in the catalogue, and three audit links pointed outside the repository. `scripts/check_content_hygiene.py` now resolves every local Markdown link and every `windows-*` identifier.
- **K4, `5336bef`: machine-specific paths.** Seven personal-profile and development-drive paths sat in tracked content. The check now scans every tracked text file. On an export of `8d6faea` it reports 12 findings (3 links, 2 identifiers, 7 paths), and 0 on `HEAD`.
- **K5, `61b92a9`: the source-review interval is enforced.** The 90-day interval was data that no script read. `scripts/check_source_register.py` now fails on an undated, overdue or malformed row and warns 14 days ahead. See the [calendar](#calendar-of-date-triggered-gates).
- **K6, `956a424`, `8acc8e5`, `9df4752`: routing coverage and a floor.** 39 fixtures were added for eight specialists, and `routing_smoke_test.py` fails below 11 covered specialists. Eight remain uncovered, and model routing is `NOT_ASSESSED`.

### Currency and documentation

- **K7, `8e7445f`: primary-source currency, dated.** Nine register rows were read from Microsoft Learn on 2026-10-31 and now carry `verified`, `review_by` and `support_state`; three are `partial`. [The review](docs/research/currentness-2026-10-31.md) records the gaps, which stay `NOT_ASSESSED`.
- **W5, `f798f5b`: worked plans and a scoped review.** The Group Policy pilot and the file-share plan are linked from `windows-group-policy` and `windows-troubleshooting`. They cover 2 of 20 skills and replace no real change packet.
- **`b63f7e7`, `7b7bf03`, `561e0e4`, `d58f727`: documentation that states what runs where.** Each gate has an exact command, a measured result and a PowerShell note, and the date-triggered gates have a calendar.

### What this does not show

- The two service fixtures and the PowerShell syntax check last ran on 29 October under PowerShell 7.4.2, which loses support on 2026-11-10.
- No Windows integration, domain, fleet window, canary or timed restore has run.
- `Invoke-WseServiceState` still does not evaluate its window or authority, and the fleet manifest still has no canary field (see the [open findings](#open-findings-that-matter-to-a-user)).
- Scores are reviewer judgements, and the 95 target is not met.

## References

The engine stores citations only. No book text or source conversion is kept in this repository (see `AGENTS.md`, "Never store book extractions").

- [docs/references.md](docs/references.md) lists the books, repositories, standards, official Microsoft sources and websites that the skills cite.
- The live register is `engine/source-register.yaml`.
- The repository is at <https://github.com/peterbamuhigire/windows-admin-engine-skills>.

## Contributing, author and licence

- Add a skill only for a repeated, distinct responsibility. Update its catalogue entry, routing fixtures, source map, tests and safety audit in the same change. Do not weaken a validator by adding findings to a baseline (`AGENTS.md`, "Change discipline").
- Run the registered validators in [Validation](#validation) before proposing a change.
- Author: Peter Bamuhigire. Licence: GPL-3.0-only, in [LICENSE](LICENSE).
