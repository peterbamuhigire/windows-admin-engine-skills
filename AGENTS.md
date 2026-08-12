# Windows Administration Skills Engine Agent Guide

## Purpose

This repository is the canonical, runner-neutral engine for safe Windows host,
domain, fleet, and hybrid administration. `SKILL.md` files are operational
procedures; `WindowsSkills.Engine` is the shared PowerShell safety and evidence
boundary; the Python package owns catalogue, routing, schema, and report work.

## Start here

1. Read this file and `windows-sysadmin/SKILL.md`.
2. Route to the narrowest specialist listed in `engine/catalog.yaml`.
3. Inspect the target and management-plane owner before suggesting a change.
4. Default to read-only discovery. A mutation requires explicit target,
   authority, risk class, change plan, stop condition, verification, and
   recovery path.
5. Mark unavailable live or lab evidence `NOT_ASSESSED`; never infer success.

## Operating rules

- Never guess a hostname, domain, tenant, subscription, cluster, or identity.
- Never accept passwords, tokens, LAPS values, recovery keys, or private keys
  as ordinary command-line arguments or evidence fields.
- Never reboot, alter remote access, firewall, DNS, GPO, identity, certificates,
  storage, or security controls without the risk-specific approval contract.
- Use `-WhatIf`/`ShouldProcess` for PowerShell mutations and capture before/after
  state. A zero exit code is not outcome verification.
- Preserve per-target outcomes. Partial fleet success is not success.
- Detect effective management ownership (local, GPO, MDM, DSC, ConfigMgr, Arc,
  or vendor) before mutation; do not start a competing control loop.
- Keep external books and source conversions outside Git. Commit only concise,
  independently organised synthesis and bibliographic attribution.
- Use official current documentation and disposable-lab evidence for volatile
  platform claims. Historical books may explain concepts, not current support.
- Do not execute third-party cookbook scripts directly. Review and re-engineer
  the required operation behind this engine's contracts.

## Risk classes

| Class | Boundary |
|---|---|
| R0 | Read-only discovery with target resolution, redaction, and evidence |
| R1 | Reversible local change with preview, before/after, and rollback |
| R2 | Service-impacting change with maintenance context and health checks |
| R3 | Access/disconnect risk with out-of-band access or timed recovery |
| R4 | Identity/security-boundary change with peer review and staged rollout |
| R5 | Destructive or hard-to-reverse change with backup proof and explicit authority |

## Quality gates

Run from the repository root:

```powershell
python -X utf8 scripts/validate_engine.py
python -X utf8 scripts/routing_smoke_test.py
python -X utf8 scripts/source_ingestion_guardrail.py
python -X utf8 -m unittest discover -s tests/python -v
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-powershell.ps1
```

Pester and live Windows-lab checks are separate gates. If their runtime or lab
is absent, record `NOT_ASSESSED`; static checks do not replace them.

## Cross-engine routes

- Software implementation, APIs, Python, CI, or packaging: `skills-web-dev`.
- Formal requirements, test, deployment, or governance artefacts: `srs-skills`.
- Current or uncertain platform/security claims: `digital-research-skills`.
- Linux hosts: `linux-skills`.
- Accounting or finance operations: `chwezi-accounting-doctrine`.

## Change discipline

Preserve user work and unrelated changes. Add a skill only for a repeated,
distinct responsibility. Update its catalogue entry, routing fixtures, source
map, tests, and safety audit in the same change. Do not weaken a validator by
adding findings to a baseline.
