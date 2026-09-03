# Windows Administration Skills Engine

This is an open-source Windows administration engine for safety-first procedures
and tooling across workstations, servers, Active Directory, networking,
security, storage, virtualisation, recovery, and fleet administration. It
develops one target-resolved change at a time, preserving authority, preview,
before/after state, health verification, recovery, and rollback evidence for
operators and automation.

The project serves two audiences:

- operators can run the `wsa-*` commands without an AI session;
- agents and automation can route requests to the appropriate `SKILL.md` and
  use the same target, authority, evidence, verification, and recovery rules.

The default posture is read-only discovery. A procedure being present in the
catalogue does not mean that its mutation path is approved or lab-validated.

This repository is the eleventh canonical skill engine in the shared
[`skills-web-dev` control plane](docs/control-plane-adoption.md). Its Windows
doctrine and safety rules remain local to this repository.

## Project status

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
