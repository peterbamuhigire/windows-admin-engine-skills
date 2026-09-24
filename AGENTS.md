# Windows Administration Skills Engine Agent Guide

## Codex-only model setup and Kaizen review

Apply this section only when the active runner is Codex. Claude and other
runners must skip it and retain their own models and full engine capabilities.

Before substantive Codex work, resolve this engine's directory and an available
Python 3.11+ interpreter (use its absolute path if absent from PATH), then run
`python <engine-root>/.codex/ensure_model_policy.py --runtime codex --check`.
If it reports configuration drift, Peter authorises the bounded
`--runtime codex --apply` repair, followed by `--check`. The helper backs up
changes and preserves unrelated settings. If Python or configuration access is
unavailable, report the limitation; do not replace the user's config wholesale.
Read `.codex/model-policy.md` for the full contract. Use Astra (`gpt-6-astra`)
for the root/orchestrator and reviewer; explicitly pin execution subagents to
Luna (`gpt-5.6-luna`). Delegate bounded work when useful and keep final review
with Astra. A running session may need restarting for root settings to apply.

Every Kaizen cycle MUST check latest official model releases and actual
runtime availability, record dated evidence and a retain/change decision,
and evaluate better candidates before recommending replacement. Preserve the
pins until Peter authorises a verified change. Missing model-currentness
evidence is `NOT_ASSESSED`. This Codex adapter must not change CLAUDE.md,
Claude configuration, domain doctrine, permission settings or skill access.

## Purpose

This repository is the canonical, runner-neutral engine for safe Windows host,
domain, fleet, and hybrid administration. `SKILL.md` files are operational
procedures; `WindowsSkills.Engine` is the shared PowerShell safety and evidence
boundary; the Python package owns catalogue, routing, schema, and report work.

## Never store book extractions

Book extractions, summaries and chapter-by-chapter notes must never be stored in this repository
(no `book-extractions/`, `extracted-books/` or `book-study/` folder, no `*-extraction.md` book
digests). Books enter only as paraphrased, task-oriented skill content with a short citation.
The portfolio check `chwezi-engine-agents/scripts/validate-no-book-extractions.py` enforces this.

## Rules

Always-on cross-cutting principles live in `rules/` — see `rules/README.md`.
Load `rules/common/core.md` alongside the routed skill for any non-trivial task;
it is short and does not replace the skill, only sets the baseline the skill
operates within.

## Mandatory Digital Research currentness gate for Kaizen

Every Kaizen audit, skill edit, reference update, validator change, and
standardisation decision MUST begin with the Digital Research Engine at
`C:\wamp64\www\digital-research-skills`. Read its `source-evaluation` and
`source-verification` skills and the currentness gate reference
`docs/continuous-improvement/kaizen-currentness-gate.md`.

Before admitting any standard, policy, law, technology, platform capability,
software version, command, security control, benchmark, or lifecycle claim,
record source scope, publication/version date, access date, freshness class,
review date, support status, and uncertainty. Use current authoritative
primary sources; quarantine stale/ambiguous/unsupported claims and mark them
`NOT_ASSESSED`. Books are durable concept inputs only.

## Start here

1. Read this file and `skills/windows-sysadmin/SKILL.md`.
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

### Machine-error editorial gate (ME1-ME7)

Apply Digital Research's `docs/continuous-improvement/machine-errors-editorial-gate-2026-09-03.md`
to administration runbooks, findings, change records, and operator explanations. Check ME1-ME7 for
repeated meaning, decorative symmetry, over-explanation, inflated consequence, generic examples,
rhetorical mannerisms, and insight-shaped filler. Preserve repeated command syntax, safety warnings,
rollback steps, target fields, and evidence labels when their operational function is documented;
otherwise cut or merge. Missing live or lab evidence remains `NOT_ASSESSED`.
Coverage record: ME1, ME2, ME3, ME4, ME5, ME6, and ME7.

### Impeccable-derived AS overlay

When a runbook, dashboard, presentation, or rendered change record contains visual output, apply
AS1-AS7. Purple gradients, glassmorphism, neon glow, AI-beige defaults, decorative editorial
scaffolding, and decorative motion are no-ship choices. For text-only operations use AS1, AS3, AS5,
and AS6; mark visual checks `not_applicable`. Preserve repeated command syntax, safety warnings,
rollback steps, target fields, and evidence labels when their operational function is documented;
unavailable lab, browser, or render evidence remains `NOT_ASSESSED`.
AS1-AS7 coverage is explicit: AS2, AS4, and AS7 are `not_applicable` for text-only operations, while
visual or rendered operational artefacts require the full overlay.

- Shared agent, hook, evidence, and handoff contract:
  `docs/control-plane-adoption.md`; this repository is registered as the
  eleventh canonical engine in `chwezi-dev-engine/docs/engine-control-plane.json`.
- Software implementation, APIs, Python, CI, or packaging: `chwezi-dev-engine`.
- Formal requirements, test, deployment, or governance artefacts: `srs-skills`.
- Current or uncertain platform/security claims: `digital-research-skills`.
- Linux hosts: `linux-skills`.
- Accounting or finance operations: `chwezi-accounting-doctrine`.

## Change discipline

Preserve user work and unrelated changes. Add a skill only for a repeated,
distinct responsibility. Update its catalogue entry, routing fixtures, source
map, tests, and safety audit in the same change. Do not weaken a validator by
adding findings to a baseline.

## DOMAIN PROMPT GENERATION CONTRACT

For a prompt handoff, read the local [domain prompt contract](docs/ai-prompting/domain-prompt-compilation-contract.md). Generate a ready-to-paste administration prompt with exact target, management owner, current state, one operation, risk class, approval boundary, staged commands, before/after evidence, health checks, rollback, and stop conditions. Never guess credentials, targets, versions, or live state. **Ready-to-paste prompt:** include assumptions and NOT ASSESSED gaps. **Failure action:** stop, recover, or revise one reversible step.

## PORTFOLIO CRAFT CONTRACT

Load `C:\wamp64\www\chwezi-engine-agents\docs\operations\portfolio-craft-standard-2026-09-04.md` when available. Run administration work as small controlled slices: frame the target and consequence, select one change, inspect the management owner and current state, preview it, apply only the bounded mutation, verify health and failure behaviour, refine the procedure, and record rollback evidence. Do not generate a full fleet change or runbook as an opaque batch. Apply `Observe -> Baseline -> Select -> Experiment -> Check -> Standardise -> Teach -> Re-measure` to kaizen itself. Missing host, lab, source, live, or recovery evidence is `NOT ASSESSED`, never a pass.
