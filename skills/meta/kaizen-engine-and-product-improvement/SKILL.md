---
name: windows-kaizen-engine-and-product-improvement
description: Use when auditing or improving the Windows administration engine or a Windows diagnostic, automation, fleet, security, recovery, or management product it produces.
metadata:
  portable: true
  compatible_with:
  - claude-code
  - codex
---

# Windows Kaizen Engine and Product Improvement

Use this skill to turn Windows operational evidence, incidents, drift, user feedback, and
current source changes into small, reversible, testable improvements.

## Use when

- Auditing the Windows engine, its routes, references, validators, fixtures, or a Windows
  administration deliverable.
- Converting a failed diagnostic, change, recovery exercise, or fleet rollout into a standard.
- Adding a book-derived improvement to the Windows engine.

## Do not use when

- A single inventory, network, identity, patch, security, or recovery task is sufficient; route
  to the narrow owner.
- A current Microsoft, standards, security, policy, or lifecycle claim has not passed Digital
  Research source evaluation and verification.

## Inputs

| Input | Required | Purpose | If absent |
|---|---:|---|---|
| Target, management plane, scope, owner, and authorization | yes | Bound the change safely | Read-only plan or `NOT_ASSESSED` |
| Current evidence, failure mode, and baseline | yes | Avoid opinion-only scoring | Do not infer quality |
| Risk class R0-R5, rollback, and success measure | yes for execution | Control impact and acceptance | No mutation |

## Platform and privilege boundary

Default to R0/read-only. R1-R5 actions require explicit authorization, the named target and
management plane, least privilege, and a documented rollback. Host, domain, cloud, and fleet
planes are distinct scopes; do not assume authority transfers between them.

## Workflow

1. Read the Windows engine `AGENTS.md`, catalogue, applicable narrow skill, and the currentness
   sources. Resolve the target and management plane before collecting evidence.
2. Establish a read-only baseline. Publish `min(raw_score, 65)` and keep blockers,
   uncertainty, and `NOT_ASSESSED` evidence separate.
3. Select one root cause and one reversible improvement. Define owner, hypothesis, measure,
   R0-R5 risk class, guardrail, stop/rollback rule, acceptance evidence, and re-audit date.
4. Prefer `-WhatIf`/`ShouldProcess`, validated parameters, least privilege, bounded scope,
   canary/ring rollout, explicit errors, transcripts, and per-target outcomes. Never expose
   secrets or run copied exploit material.
5. Validate failed paths, recovery, event/process/network evidence, and relevant native
   validators. If evidence fails, recover the last safe state and record the learning.
6. Standardise only accepted learning in the owning skill, reference, catalogue, fixture, or
   validator; rerun routing and source-ingestion gates.

## Mutation, verification, and recovery

Inspection does not mutate. Any mutation must be previewable with `-WhatIf`/`ShouldProcess`
where applicable, bounded to the approved target, and recorded with per-target outcomes.
Verify the original symptom or control objective, then prove rollback or recovery in a safe
fixture/canary before wider adoption.

## Stop conditions

Stop on wrong target or management plane, missing authorization, secret exposure, unbounded
scope/concurrency, unexpected output, failed prerequisite, failed rollback, or unavailable
evidence that makes the risk unknowable. Recover the last safe state and mark the result
`NOT_ASSESSED` when verification cannot run.

## Outputs

- Capped scorecard with evidence, blockers, and residual risk.
- 95/100 improvement plan with a named owner, experiment, guardrail, rollback, and proof.
- Standardisation record, per-target results, and next review trigger.

## Capability contract and degraded mode

Read and bounded execution are allowed within the approved risk class. Mutation requires
explicit authorization and a recoverable change packet. Without target access, lab evidence,
or a required validator, provide a conditional plan and mark the affected dimension
`NOT_ASSESSED`; never convert unavailable evidence into a pass.

## References

- [Book-driven Kaizen Wave 3](references/book-driven-kaizen-wave-3-2026-09-02.md)
- `AGENTS.md` and the Windows engine catalogue
- Digital Research source-evaluation and source-verification routes

## Decision rules

| Condition | Action | Failure avoided |
|---|---|---|
| Evidence isolates a narrow subsystem | Hand off to its specialist | Duplicate or broad mutation |
| A change is reversible and passes canary evidence | Standardise and schedule re-audit | One-off learning loss |
| A currentness or safety gate fails | Stop, quarantine the claim, and recover | Obsolete or unsafe operation |
| A target, rollback, or owner is unclear | Remain read-only and define the gap | Uncontrolled impact |

## Quality standards

Every finding has source evidence, target, owner, risk class, uncertainty, measure, and
acceptance proof. Every mutation has preview or change evidence, per-target result, rollback,
and recovery verification. Current Windows and standards claims carry source/date/freshness.

## Anti-patterns

- Broad all-host mutation. Fix: bounded target and canary/ring rollout.
- Copying a Unix command into PowerShell. Fix: verify Windows-native behavior and sources.
- Treating a successful command as a successful outcome. Fix: verify the original objective.
- Hiding unavailable lab evidence. Fix: mark `NOT_ASSESSED` with consequence.
- Running an agent or script with implicit privilege. Fix: explicit authority and least privilege.

## Quality gate

Run the Windows catalogue validator, routing smoke test, source-ingestion guardrail, Python
tests, and PowerShell tests before declaring an engine change ready.
