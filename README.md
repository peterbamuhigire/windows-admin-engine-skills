# Windows Administration Skills Engine

A runner-neutral Windows operations engine for workstations, servers, Active
Directory, network services, security, storage, virtualisation, recovery, and
bounded fleet administration.

The engine separates three concerns:

- `windows-sysadmin/` and numbered specialist `SKILL.md` files hold human- and
  agent-readable operating procedures.
- `powershell/WindowsSkills.Engine/` owns Windows-native target, operation,
  redaction, evidence, inventory, health, and controlled-change primitives.
- `python/windows_admin/` owns catalogue validation, routing, schema checks,
  fleet-safe planning, and cross-platform CLI behaviour.

## Current release boundary

Release 0.1 implements the control plane and useful read-only local inventory,
health, network, event, security, storage, service, IIS, Hyper-V, AD discovery,
and routing workflows. It includes one bounded service-state mutation to prove
the R2 contract. Domain, GPO, firewall, storage-destructive, patch/reboot,
certificate, backup-restore, and fleet mutations remain gated until their lab
rows have executable evidence.

This is deliberate: a catalogue entry or script example is not proof that an
operation is safe on a real estate.

## Quick start

```powershell
# Validate the checkout without changing the host
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py

# Discover routes
python -X utf8 -m windows_admin.cli --repo . list
python -X utf8 -m windows_admin.cli --repo . route "check AD replication health"

# Native local inventory; writes a redacted evidence pack under .evidence/
Import-Module .\powershell\WindowsSkills.Engine\WindowsSkills.Engine.psd1 -Force
Get-WseSystemInventory -EvidenceRoot .\.evidence
```

When running the Python module directly, either install the local package or set
`PYTHONPATH` to the repository's `python` directory. The wrapper
`scripts/windows-admin.ps1` handles that automatically.

## Repository map

```text
AGENTS.md                         repository policy and safety boundary
windows-sysadmin/SKILL.md         default router
01-*/.../SKILL.md                 specialist procedures
engine/                           catalogue, schemas, platforms, sources
powershell/WindowsSkills.Engine/  Windows-native module and Pester tests
python/windows_admin/             catalogue/router/schema CLI package
scripts/                          validation, CLI, install and test wrappers
templates/                        skill, change, rollback, evidence templates
tests/                            routing, schema, fixture and Python tests
labs/                             declared disposable lab topologies
docs/                             decisions, research, audits and operations
```

## Safety model

The default is R0 read-only discovery. Changes use R1-R5 controls defined in
`AGENTS.md` and `docs/safety-model.md`. The engine refuses an ambiguous target,
unknown policy owner, missing change authority, unsupported platform, or missing
recovery prerequisite. It never treats request wording as approval.

Every operation uses the versioned result fields in
`engine/schemas/operation-envelope.schema.json`, including `Changed`,
`RebootRequired`, `DisconnectRisk`, `Before`, `After`, `Verification`,
`RollbackArtifact`, `EvidencePath`, `Errors`, and `Warnings`.

## Source policy

The supplied PowerShell, Active Directory, Sysinternals, and Windows Internals
books informed topic coverage and failure hypotheses. No raw book text or code
was copied into this repository. `docs/research/source-synthesis.md` records the
independent synthesis and its limits; `engine/source-register.yaml` records
provenance and freshness. Current product behaviour must be rechecked against
official documentation and a disposable target before promotion.

## Validation

```powershell
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py
python -X utf8 scripts/source_ingestion_guardrail.py
python -X utf8 -m unittest discover -s tests/python -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

See `docs/testing/test-plan.md` for live lab gates and
`docs/release/delivery-evidence-pack.md` for the current verdict.
