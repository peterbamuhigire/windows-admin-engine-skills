# Book-driven Kaizen operating system

This reference is an independent synthesis of durable ideas from the supplied
improvement, human-agent orchestration, supply-chain, instructional-design,
finance, business-system, replication, and storytelling books. It is not a book
transcript and does not establish current Windows commands, support status,
security controls, or Microsoft policy.

## Aim, measures, and PDSA

State the operational aim, user or service outcome, baseline, owner, and guardrail
before changing a host or fleet. Treat the change as a small PDSA experiment:
plan the hypothesis and rollback, do it in a bounded scope, study before/after
evidence, and act by standardising, adapting, pausing, or reversing. A zero exit
code or operator satisfaction is not proof of the intended outcome.

Use measures that expose both value and harm: task or service success, incident
rate, recovery time, capacity, latency, patch compliance, availability, operator
rework, security exposure, and evidence completeness. Keep leading indicators,
transfer behaviour, and business results separate.

## Repeatable core and bounded adaptation

Build a repeatable core for target resolution, management ownership, authority,
preview, evidence, verification, rollback, redaction, and escalation. Allow
bounded adaptation for Windows edition, role, topology, language, management
plane, workload, and local policy only when the variation is named, tested, and
does not weaken the invariant safety contract.

Document the runbook, decision rights, prerequisites, handoffs, training,
support path, exception expiry, and re-audit date. Replication means preserving
the outcome and controls, not copying a command sequence into a new environment.

## Fleet scenario and sensitivity

Model a fleet as a network of hosts, identities, sites, management planes,
dependencies, capacity limits, and recovery paths. Validate the actual baseline
before comparing alternatives. For a canary or rollout, show ring size,
concurrency, rate limits, failure threshold, circuit breaker, retry safety,
rollback capacity, and per-target evidence.

Test sensitivity to reachability, authentication, policy ownership, bandwidth,
maintenance-window length, reboot duration, service dependency, backup age, and
partial failure. A central job result never replaces local outcome verification;
partial fleet success remains partial.

## Agent decision rights and recovery

For every agent or automation path, declare task boundary, target scope, tools,
data class, autonomy level, side-effect budget, approval gate, escalation rule,
kill switch, containment, recovery owner, and audit events. Increase autonomy only
after reliability and safety evidence supports the next tier. Consequential,
ambiguous, access-affecting, or destructive actions remain human-approved.

## Learning transfer

Convert a runbook into operator capability through explain -> demonstrate ->
practise -> assess -> support -> observe transfer -> measure result. Assess the
critical behaviour, not only attendance or reaction. For recovery, patching,
identity, and security work, require a representative exercise, named evaluator,
failure path, and measured RPO/RTO, restoration, access, or service outcome.

## Currentness gate

Books provide durable concepts only. Current Windows, PowerShell, Active
Directory, Entra, Intune, Azure Arc, security-baseline, lifecycle, protocol,
policy, and Microsoft-platform claims must pass Digital Research source evaluation
and source verification. Use the claim-specific entries in
`engine/source-register.yaml` and the portfolio manifest at
`C:\wamp64\www\skills-web-dev\docs\source-registers\skills-engine-currentness-2026-09.json`, verify official current documentation, record
source scope and access/review dates, and mark stale or unavailable evidence
`NOT_ASSESSED`. Never promote a historical recipe to a current procedure without
current-source and disposable-lab evidence.

## Adoption checklist

- Aim, baseline, measure, guardrail, owner, and decision threshold are explicit.
- Invariant safety controls and bounded environmental adaptations are separated.
- Target, management plane, authority, risk class, preview, rollback, and oracle are recorded.
- Fleet scenarios include canary, capacity, sensitivity, circuit-breaker, and per-target evidence.
- Operator learning transfer and post-change behaviour are observable.
- Agent autonomy and side effects are bounded and auditable.
- Current claims have verified primary sources; missing lab or live evidence remains visible.
