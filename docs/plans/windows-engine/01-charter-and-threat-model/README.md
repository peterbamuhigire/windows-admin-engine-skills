# Phase 01 — Charter, mission, and threat model

## Purpose

Turn the ambition of “manage Windows environments to perfection” into a bounded, testable product charter. Establish who may use the engine, which environments are supported, which operations are forbidden or human-gated, and what evidence constitutes a trustworthy completion.

## Workstreams

### 1.1 Product charter

- Name the engine owner, engineering owner, security reviewer, lab owner, release owner, and incident owner.
- Define operator personas: workstation administrator, small-business administrator, domain administrator, network administrator, security analyst, developer, help-desk operator, and AI agent.
- Define target environments: personal workstation, workgroup, member server, domain controller, file server, IIS host, Hyper-V host, Windows 11 fleet, Windows Server fleet, and hybrid estate.
- Define the first release promise and explicit non-goals.
- Set a principle that a skill is a workflow with evidence, not a pile of commands.

### 1.2 Threat model

Model misuse and failure, including:

- wrong host, wrong tenant, wrong domain, or stale inventory;
- an AI agent inferring permission from a user request;
- credential, token, LAPS secret, private key, or sensitive directory export leakage;
- remote firewall or WinRM changes cutting off the operator;
- rebooting the wrong machine or interrupting a clustered role;
- partial fleet execution with inconsistent outcomes;
- malicious repository content or prompt injection in documentation;
- tampered scripts, unsigned modules, dependency substitution, and PATH hijacking;
- incorrect interpretation of localized output, registry views, event IDs, or policy ownership;
- rollback that restores configuration but not service health; and
- an operator treating a report as proof when the live target was not tested.

### 1.3 Decision register

Create ADRs for:

- supported Windows editions and lifecycle policy;
- Windows PowerShell 5.1 versus PowerShell 7;
- PowerShell versus Python ownership;
- remoting protocols and authentication;
- local, remote, fleet, and cloud target boundaries;
- signing and execution policy;
- evidence retention and redaction;
- lab topology and snapshot policy;
- catalog and artifact schemas; and
- the meaning of validated, partial, experimental, blocked, and not assessed.

## Required artifacts

- PROJECT-BRIEF.md
- owner and authority matrix
- threat model with assets, actors, trust boundaries, threats, controls, and residual risks
- ADR index with decision status and review dates
- first-release scope and non-goals
- glossary
- initial risk register
- 20 representative operator prompts, including ambiguous and unsafe requests

## Verification

- Ask an independent reviewer to route the prompts without seeing the intended answer.
- Confirm every high-risk operation has a named authority, target, approval, and recovery expectation.
- Confirm the charter does not claim universal Windows or third-party product coverage.
- Record unresolved decisions as blockers rather than guessing.

## Exit gate

Do not begin implementation until the owner approves the scope, the threat model covers local and remote operation, the first release has measurable boundaries, and every high-risk class has a stop rule.

## Dependencies and risks

Depends on the Linux engine audit and current Microsoft source review. The principal risk is building a broad catalogue before deciding the safety and evidence contract. The corrective action is to keep this phase short, explicit, and approval-driven.
