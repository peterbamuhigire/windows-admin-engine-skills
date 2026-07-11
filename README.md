# Windows Skills Engine

A portable, AI-assisted skills engine for Windows system administration, networking, security, and development.

It is designed as a hub-and-specialist system: a small routing layer classifies a request, then hands it to the right skill. Each skill owns one clear workflow, with manual procedures, optional PowerShell acceleration, and explicit safety rules.

## What it is

Windows Skills Engine is a repository of focused administrative skills for Windows environments. It is intended to help operators and AI agents perform tasks safely, consistently, and with strong evidence trails .

The engine emphasizes:
- Clear routing to the right specialist skill.
- Read-only discovery before mutation.
- Structured output instead of ad hoc text.
- Reboot and disconnect-risk awareness.
- Idempotent, testable workflows.
- Evidence packs for change and compliance operations.

## Why it exists

Windows administration has many first-class dimensions that deserve explicit handling: server vs client, Server Core vs Desktop Experience, PowerShell 5.1 vs PowerShell 7, local vs remote execution, GPO vs MDM, and operations that may require reboot or risk lockout [file:1].

This project exists to turn that complexity into a controlled, trustworthy system rather than a loose collection of scripts.

## Core principles

- One skill, one responsibility.
- Manual truth first, scripts as accelerators.
- Schema-driven inventory, not duplicated documentation.
- Safety gates for destructive or disconnect-risk changes.
- Structured records by default.
- Every validated workflow has evidence.

## Repository structure

A recommended structure includes:
- `windows-skills/` for the repository root.
- `windows-sysadmin/` for the routing hub.
- `SKILL.md` files for each specialist skill.
- `engine/catalog.yaml` as the authoritative inventory.
- `engine/catalog.schema.json` for validation.
- `powershell/WindowsSkills.Engine/` for shared automation primitives.
- `references/` for curated guidance and decision aids.
- `tests/` for unit, contract, integration, and lab validation.
- `docs/` for architecture, roadmaps, and quality gates.

## Example skills

Initial high-value skills may include:
- `windows-system-inventory`
- `windows-health-assessment`
- `windows-network-admin`
- `windows-security-analysis`
- `windows-event-logs`
- `windows-active-directory` 

Over time, the engine can grow into provisioning, identity, policy, storage, virtualization, observability, recovery, patching, compliance, endpoint management, and hybrid cloud workflows.

## Safety model

The engine is built to avoid unsafe assumptions:
- Discovery happens before mutation.
- Remote lockout-risk changes require special care.
- Reboots are explicit, not implicit.
- Rollback paths are documented where possible.
- Secrets and sensitive values are redacted from evidence.
- Unsupported platform combinations are clearly marked.

## Output model

Skills should return structured data where possible, such as:
- `Changed`
- `RebootRequired`
- `RollbackAvailable`
- `Verification`
- `EvidencePath`

Human-friendly formatting should stay at the presentation layer, not inside every function.

## Installation

The recommended distribution model is:
1. Use the repository directly for agent-based workflows.
2. Publish the engine as a versioned PowerShell module.
3. Provide an installer for trusted local or offline deployment.
4. Verify signatures, hashes, and installed version metadata.
5. Support install, update, repair, uninstall, and test operations.

## Quality gates

A skill should not be marked validated unless it has:
- A clear responsibility and handoff boundary.
- A platform support matrix.
- Required inputs and identity context.
- Read-only discovery before mutation.
- Idempotency or an explicit exception.
- Pre-change capture and post-change verification.
- Rollback handling or an honest fallback statement.
- Positive, negative, and second-run tests.
- A sanitized exemplar workflow.
- Fresh, authoritative references.

## License

Add your chosen license here.

## Status

This project is a blueprint for a production-grade Windows skills engine. The next step is to finalize the repository name, scope, and supported platforms, then implement the core hub, catalog, and shared PowerShell engine.
