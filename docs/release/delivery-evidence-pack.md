# Delivery evidence pack: Windows Administration Skills Engine 0.1

## Artefact identity

| Field | Value |
|---|---|
| Project | Windows Administration Skills Engine |
| Deliverable | 0.1 control plane, skills, native module, CLI, direct commands, validation |
| Owner | Peter Bamuhigire |
| Reviewer | Independent reviewer not yet assigned |
| Date | 2026-08-12 |
| Related engines | skills-web-dev, srs-skills, digital-research-skills, linux-skills |

## Decisions

| Decision | Rationale | Reversal trigger |
|---|---|---|
| PowerShell owns Windows-native mutation | Native Windows management surfaces | An API becomes the authoritative safer owner |
| Python owns catalogue/routing/schema | Dependency-free and CI-friendly | Contract needs a Windows-only API |
| Script-first operator surface | Avoid model cost for repeatable tasks | A command cannot preserve safety/evidence |
| R3-R5 blocked by default | Recovery proof is absent | Capability-specific lab passes |

## Contract evidence

| Contract | Location | Result |
|---|---|---|
| Catalogue and source/platform registers | `engine/` | PASS |
| Operation/evidence/fleet schemas | `engine/schemas/` | PASS structurally |
| PowerShell module | `powershell/WindowsSkills.Engine/` | PASS local 5.1 |
| Direct command catalogue | `engine/command-catalog.json`, `commands/` | PASS, 48 commands |
| Target/authority/rollback | safety model and templates | PASS contract; live high-risk proof absent |

## Test evidence

| Gate | Result |
|---|---|
| Engine validator | 16 skills, zero findings |
| External portable quick validator | 18 checked directories, zero failures |
| Routing | 16 fixtures, zero failures |
| Source ingestion | zero findings |
| Source URL identity/liveness | 36/36 reachable; semantic support remains separately reviewed |
| Command tree | 48 direct commands, zero findings |
| Fleet manifest | one target, zero findings, no contact |
| Python unittest | 8 passed |
| PowerShell syntax | 70 files, zero findings |
| PowerShell local smoke | inventory succeeded; EventLog preview only |
| Evidence pack | write, hash, and validation passed in OS temp storage |
| Pester 3.4 | 3 passed |
| Git diff check | zero whitespace errors |
| Installer | `-WhatIf`: 51 dirs, 49 names, zero collision, PATH 4,213 chars |
| PSScriptAnalyzer | NOT_ASSESSED: module unavailable |
| PowerShell 7 | NOT_ASSESSED: `pwsh` unavailable |
| Server/AD/Hyper-V/IIS/remoting/recovery/fleet labs | NOT_ASSESSED |

## Operational evidence

- Read-only commands and evidence writes work on the local Windows 11 host.
- The installer was previewed only; it did not change the current user PATH.
- Uninstall removes only exact command-root entries and deletes no repository file.
- Signing, SBOM, canary, production owners, incident, and live rollback proof are blockers.

## Source and anti-slop evidence

The source register distinguishes official current anchors, secondary books,
and historical-only material. No raw source or download path entered the tree.
The safety and A-grade anti-slop audits are stored beside this record.

## Release verdict

| Gate | Verdict | Note |
|---|---|---|
| Architecture | PASS | Clear native/orchestration/skill/command boundaries |
| Security | PARTIAL | Safe scope; signing/redaction/high-risk labs open |
| Reliability | PARTIAL | Local evidence only |
| Data/evidence | PASS structurally | Negative redaction/tamper suite remains open |
| Docs/runbook | PASS for development | Production support roles absent |
| Anti-slop | PASS | A / genericness 14 |

Final decision: ship as a development and read-only local 0.1 engine. Hold
production mutation, fleet execution, identity/GPO/security enforcement,
destructive storage, reboot, and restore until the named blockers close.
