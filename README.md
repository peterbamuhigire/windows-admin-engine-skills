# Windows Administration Skills Engine

`windows-admin-engine-skills` is a 20-skill, safety-first Windows administration engine covering workstations, servers, Active Directory, networking, security, storage, virtualisation, recovery, and fleet administration, plus a dedicated portability-doctrine skill for the tooling (installers, hooks) every Chwezi engine runs on Windows. It develops one target-resolved change at a time, preserving authority, preview, before/after state, health verification, recovery, and rollback evidence, against a six-tier risk model (R0 read-only discovery through R5 destructive/hard-to-reverse). It serves two audiences: operators who run the `wsa-*` commands directly without an AI session, and agents/automation that route a request to the matching `SKILL.md` and follow the same target/authority/evidence/verification/recovery rules. Windows sysadmins, AD administrators, fleet/endpoint managers, and other Chwezi engines needing a Windows-native operation use it for concrete cases such as: checking Active Directory replication health (`identity-active-directory-and-access/windows-active-directory-health`), collecting a redacted local inventory before a change (`inventory-health-and-diagnostics/windows-system-inventory`), starting/stopping a local service under `ShouldProcess` and maintenance-window control — the one shipped mutation accelerator (`wsa-service-state`), or auditing another engine's `install.sh`/`install.ps1` for real cross-platform correctness against four documented incident classes (`meta/windows-portability-doctrine`). The default posture is read-only discovery: a procedure's presence in the catalogue does not mean its mutation path is approved or lab-validated. This repository is the eleventh canonical skill engine in the shared [`skills-web-dev` control plane](docs/control-plane-adoption.md); its Windows doctrine and safety rules remain local to this repository.

Install it as a native Claude Code plugin, or npm-free from a clone:

```
# Native Claude Code plugin
/plugin marketplace add https://github.com/peterbamuhigire/windows-admin-engine-skills
/plugin install windows-admin@chwezi-windows-admin

# npm-free, from a clone
git clone https://github.com/peterbamuhigire/windows-admin-engine-skills
cd windows-admin-engine-skills
./install.sh --scope project      # macOS/Linux/Git Bash
.\install.ps1 -scope project      # Windows PowerShell
```

(`chwezi-windows-admin` is the marketplace name and `windows-admin` the plugin name declared in `.claude-plugin/marketplace.json`; both installers delegate to the vendored `scripts/install-engine.js` and accept `--scope user|project`. For day-to-day operator use, the engine's own `scripts/install-windows-admin.ps1 -WhatIf`/no-flag pair — documented below under Quick start — is the PATH-registration path for the `wsa-*` commands; the two installers serve different purposes and are not interchangeable.) The one confirmed reciprocal sister engine is **linux-skills** — the estate's other infrastructure engine: this engine's own `AGENTS.md` routes Linux hosts to `linux-skills` ("Linux hosts: `linux-skills`"), and its build used `linux-skills` explicitly as the capability benchmark and reference engine during the parity-audit planning phase (`docs/plans/windows-engine/02-parity-audit-and-capability-map/README.md`, `docs/plans/windows-engine/README.md`). It is an independent, optional install — pull it in only when the estate also touches Linux hosts. A second sister, confirmed in `docs/release/delivery-evidence-pack.md`'s own "Related engines" row, is **srs-skills** (formal requirements/architecture documentation this engine's procedures can feed) alongside **digital-research-skills** for current, uncertain, or vendor-advisory claims this engine's own `rules/common/core.md` says must never be guessed.

## Capability map

| Category | SKILL.md files | Coverage |
|---|---|---|
| `virtualization-containers-and-development/` | 3 | Hyper-V, development-workstation provisioning, and Windows desktop E2E testing (pywinauto) |
| `identity-active-directory-and-access/` | 2 | Active Directory health, identity lifecycle |
| `inventory-health-and-diagnostics/` | 2 | System inventory, health assessment |
| `meta/` | 2 | `windows-sysadmin` hub-equivalent routing plus the original `windows-portability-doctrine` skill |
| `networking-and-remote-management/` | 2 | Network admin, remote management (WinRM) |
| `policy-security-and-compliance/` | 2 | Group Policy, security analysis |
| `storage-files-services-and-web/` | 2 | Storage/files/services, IIS |
| `backup-recovery-and-business-continuity/` | 1 | Backup and recovery |
| `fleet-hybrid-and-management-planes/` | 1 | Fleet and hybrid management (MDM/DSC/ConfigMgr/Arc) |
| `observability-performance-and-troubleshooting/` | 1 | Troubleshooting |
| `patching-software-and-endpoint-management/` | 1 | Patch management |
| `windows-sysadmin/` | 1 | Hub skill — start here when the responsible specialist is unclear |

20 `SKILL.md` files across 11 category directories under `skills/<category>/<skill-name>/SKILL.md` (verified 2026-09-20 by direct count).

## References

- Mustafa, A. et al. *Everything Claude Code (ECC)*. GitHub: affaan-m/ECC, 2026. — Cited by this engine's `docs/agent-runtime-safety.md` and `skills/virtualization-containers-and-development/windows-desktop-e2e-testing` (pywinauto patterns reference).
- This engine's `meta/windows-portability-doctrine` skill is this engine's **own original synthesis**, not an ECC import — its frontmatter states `origin: original synthesis for this engine, grounded in documented real incidents — not an ECC import. Sources cited inline per claim.` It exists because this engine is the only one in the estate with standing reason to actually run, diagnose, and fix things on a real Windows host, and each of its four documented incidents was found that way, not by code review alone. It draws its evidence from specific ECC troubleshooting sources, cited inline per incident:
  - Incident 1 (Git Bash/MSYS2 path-doubling): ECC's `install.sh` (`ECC-main/install.sh`, lines 27-32) and this estate's own `chwezi-engine-agents/scripts/install.sh.template` (lines 5-9, 30-32), which cites the ECC precedent explicitly in its own comment.
  - Incident 2 (symlink-chain resolution): ECC's `install.sh` lines 9-15.
  - Incident 3 (background processes killed by Windows Job Objects on hook exit): ECC's `continuous-learning-v2` skill (`ECC-main/skills/continuous-learning-v2/SKILL.md`, "Observer platform support" section), including its corroborating `ECC_OBSERVER_NOSURVIVE_WARN_AFTER` warning pattern.
  - Incident 4 (CRLF corruption of vendored shell scripts): ECC's `TROUBLESHOOTING.md` ("spawn UNKNOWN" section).
- No further citations beyond ECC were found in this engine's `rules/`, `skills/`, or `docs/research/source-synthesis.md` beyond the general statement that "external books and cookbook repositories informed capability coverage and failure hypotheses" without their scripts being executed or copied — that synthesis document names no individually citable book or author beyond ECC.

## Project status

## Prompt-generation capability — 2026-09-17

This release adds evidence-first candidate testing, failure-slice review, and explicit `NOT_ASSESSED` handling for volatile prompt claims.

Windows administration prompts now include host and PowerShell context, exact
targets, approved verbs, WhatIf/Confirm or equivalent safeguards, per-target
outcomes, logging, rollback, and explicit authority through the local [domain
prompt contract](docs/ai-prompting/domain-prompt-compilation-contract.md).

Version `0.1.0` provides the control plane, 16 routed specialist skills, and 48
direct commands. Windows 11, Windows PowerShell 5.1, and the Python 3.12 tooling
have local lab evidence dated 2026-08-12. Windows Server, domain-controller,
Hyper-V, remote WinRM, PowerShell 7, and non-English-locale rows are currently
`NOT_ASSESSED`; see the [platform matrix](engine/platform-matrix.yaml).

Most shipped commands collect state and write redacted evidence. The sole
mutation accelerator is `wsa-service-state`, an R2 local service start/stop
operation with `ShouldProcess`, change-authority, maintenance-window,
verification, and rollback controls. Higher-risk mutation paths remain blocked
until their disposable-lab and recovery gates pass.

## Quick start

### Requirements

- Windows PowerShell 5.1 for the currently lab-validated module path
- Python 3.10 or later for catalogue, routing, and schema tools
- a cloned or downloaded copy of this repository

From the repository root, validate the checkout without changing the host:

```powershell
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py
```

List the available skills and route an operator request:

```powershell
./scripts/windows-admin.ps1 list
./scripts/windows-admin.ps1 route "check Active Directory replication health"
./scripts/windows-admin.ps1 doctor
```

The wrapper sets `PYTHONPATH` for the current process, so an editable package
install is not required. To install the Python CLI in an isolated environment:

```powershell
python -m venv .venv
./.venv/Scripts/python.exe -m pip install --editable .
./.venv/Scripts/windows-admin.exe --repo . list
```

Collect a local inventory and write a redacted evidence pack under
`.evidence/`:

```powershell
Import-Module ./powershell/WindowsSkills.Engine/WindowsSkills.Engine.psd1 -Force
Get-WseSystemInventory -EvidenceRoot ./.evidence
```

Direct `wsa-*` commands can be exposed on the current user's `PATH`. Preview the
environment change first:

```powershell
./scripts/install-windows-admin.ps1 -WhatIf
./scripts/install-windows-admin.ps1
```

The same command installs, updates, or repairs the integration. It removes stale
engine-owned `PATH` entries, registers every current command directory, sets
`WINDOWS_ADMIN_ENGINE_ROOT`, verifies the result, and restores the previous
environment if the update fails. It preserves unrelated `PATH` entries and does
not copy repository files.

After pulling repository changes, run `install-windows-admin.ps1` again if
command directories were added, renamed, removed, or the checkout moved. An
edited command is available immediately, a new command placed in an already
registered directory is available immediately, and a skill-only change needs no
Windows environment update. You do not need to uninstall before updating. Use
`scripts/uninstall-windows-admin.ps1` only when removing the engine integration.

## Find the right skill

Start with [`skills/windows-sysadmin/SKILL.md`](skills/windows-sysadmin/SKILL.md)
when the responsible specialist is unclear. The machine-readable source of
truth is [`engine/catalog.yaml`](engine/catalog.yaml).

| Domain | Specialist skills |
|---|---|
| Inventory and health | `windows-system-inventory`, `windows-health-assessment` |
| Networking and remote access | `windows-network-admin`, `windows-remote-management` |
| Identity and Active Directory | `windows-active-directory-health`, `windows-identity-lifecycle` |
| Policy and security | `windows-group-policy`, `windows-security-analysis` |
| Patching and software | `windows-patch-management` |
| Storage and web workloads | `windows-storage-files-services`, `windows-iis` |
| Virtualisation and development | `windows-hyper-v`, `windows-development-workstation` |
| Troubleshooting | `windows-troubleshooting` |
| Recovery | `windows-backup-recovery` |
| Fleet and hybrid management | `windows-fleet-management` |

Routing reports risk and maturity. It does not grant authority to make a
change.

## Repository structure

```text
skills/                            router and specialist operating procedures
commands/                          standalone wsa-* command launchers by domain
engine/                            catalogues, schemas, platform and source data
powershell/WindowsSkills.Engine/   Windows-native safety and evidence module
python/windows_admin/              routing, catalogue and schema package
scripts/                           validation, installation and CLI wrappers
tests/                             Python, routing, schema and fixture tests
labs/                              declared disposable-lab topologies
templates/                         skill, operation, rollback and evidence forms
docs/                              operator guides, decisions, research and audits
```

Public runtime paths use semantic names such as `skills/networking-and-remote-management/`
and `commands/networking/`. Numbered directories appear only under
`docs/plans/windows-engine/`; that complete 01–21 sequence records the original
implementation phases and is not the current skill taxonomy.

## Safety model

Every operation begins by resolving the target and identifying its effective
management owner, such as local policy, Group Policy, MDM, DSC, ConfigMgr,
Azure Arc, or a vendor control plane. Unknown ownership is a stop condition.

| Risk | Boundary |
|---|---|
| R0 | Read-only discovery with target resolution, redaction, and evidence |
| R1 | Reversible local change with preview, before/after state, and rollback |
| R2 | Service-impacting change with maintenance context and health checks |
| R3 | Access or disconnect risk with out-of-band access or timed recovery |
| R4 | Identity or security-boundary change with peer review and staged rollout |
| R5 | Destructive or hard-to-reverse change with backup proof and explicit authority |

The engine stops on ambiguous targets, missing authority, unsupported
platforms, unavailable recovery prerequisites, cross-tenant uncertainty, or
requests to capture secrets as ordinary arguments or evidence. Read the full
[safety model](docs/safety-model.md) and repository [agent guide](AGENTS.md)
before proposing or implementing a mutation.

## Commands and evidence

The [command catalogue](docs/operations/command-catalog.md) provides a concise
index. The [operator manual](docs/operations/commands-and-scripts-manual.md)
documents syntax, prerequisites, privileges, outputs, and troubleshooting.

Operation results conform to
[`engine/schemas/operation-envelope.schema.json`](engine/schemas/operation-envelope.schema.json).
An exit code of zero is transport evidence, not proof that the requested
outcome occurred; procedures must also run their named verification oracle.

Generated evidence belongs in `.evidence/`, which Git ignores. Do not commit
host inventories, credentials, tokens, LAPS values, recovery keys, private
keys, or customer data.

## Development and validation

Run the repository gates from the project root:

```powershell
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py
python -X utf8 scripts/source_ingestion_guardrail.py
python -X utf8 -m unittest discover -s tests/python -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

Pester and live Windows-lab checks are separate gates. If their runtime or lab
is unavailable, record `NOT_ASSESSED`; static validation is not a substitute.
The current results and limitations are recorded in the
[delivery evidence pack](docs/release/delivery-evidence-pack.md).

## Kaizen P0 implementation status — 2026-09-07

The fleet manifest validator now requires an explicit `authority` object with
owner, approver, change window, and a bounded status value. The synthetic lab
fixture and `tests/python/test_fleet_manifest.py` cover accepted and rejected
authority states. This validates manifest shape only; approval authenticity,
target reachability, canary execution, rollback, and fleet readiness remain
NOT_ASSESSED.

Validated with `python -B -X utf8 -m unittest discover -s tests/python -v`: 20
tests passed. Next action is to bind the manifest to a real review record and
read-only per-target preflight evidence before enabling fleet operations.

## September 2026 B26 contract extensions

The Phase 1 fixture wave adds three bounded Windows contracts:

- [`tool-controller-contract.md`](docs/kaizen/tool-controller-contract.md)
  separates typed `WindowsSkills.OperationResult` domain objects from display
  formatting and preserves partial outcomes.
- [`pipeline-binding-review.md`](docs/kaizen/pipeline-binding-review.md)
  requires semantic entity kind/namespace checks and keeps trace diagnostics
  behind target validation and `ShouldProcess`/`-WhatIf`.
- `tests/fixtures/kaizen/powershell-semantics.json` and
  `tests/powershell/Kaizen-Semantics.Tests.ps1` cover array-switch behaviour,
  membership semantics, cancellation, and partial results.

Run the normal and failure-path checks with:

~~~powershell
python -X utf8 -m unittest tests/python/test_kaizen_contracts.py -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
~~~

These are synthetic local checks. Remote binding, management ownership,
PowerShell 7 parity, live trace capture, and production mutation evidence
remain `NOT_ASSESSED`.

## Contributing

Contributions should add a distinct, repeated Windows administration
responsibility or improve an existing contract. Before opening a pull request:

1. keep discovery read-only unless the change has an explicit R1–R5 contract;
2. update the catalogue, routing fixtures, source map, tests, and safety audit
   when a skill changes;
3. use official current documentation for volatile platform claims and record
   unavailable live evidence as `NOT_ASSESSED`;
4. run all applicable validation gates and include the exact results;
5. avoid committing generated evidence, third-party cookbook code, or copied
   book content.

Do not weaken a validator by adding new findings to a baseline. Preserve
per-target outcomes: partial fleet success must remain partial.

## Source policy

External books and cookbook repositories informed capability coverage and
failure hypotheses. Their scripts are not executed or copied into this engine.
The [source synthesis](docs/research/source-synthesis.md) explains the boundary,
and [`engine/source-register.yaml`](engine/source-register.yaml) records source
provenance and freshness.

## Licence

This project is licensed under the GNU General Public License v3.0. See
[`LICENSE`](LICENSE).

## Agent runtime safety — 2026-09-07

[`docs/agent-runtime-safety.md`](docs/agent-runtime-safety.md) records the
runner-neutral execution boundary for Windows work: untrusted repository and
tool content, disposable handoffs, approval gates, least agency, per-target
telemetry, process-group stop, and independently verified recovery.
