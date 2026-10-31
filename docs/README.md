# Documentation index

This folder holds the safety doctrine, operator manuals, evidence records and kaizen history for the Windows Administration Skills Engine. Start with the repository [README](../README.md). It opens with an at-a-glance list and three start-here steps, then covers how to find a skill, installation, validation, the current quality status and a [summary of what the October 2026 kaizen improved](../README.md#what-the-october-2026-kaizen-improved). The [full itemised list](kaizen/october-2026-improvements.md) is in this folder. Agents follow [AGENTS.md](../AGENTS.md), the router.

Dated records describe the repository on the day they were written. Their counts (skills, fixtures, tests) are not refreshed. The current measured counts are in the [README validation section](../README.md#validation).

## Safety and control

| Document | What it holds |
|---|---|
| [safety-model.md](safety-model.md) | Target contract, roles, mutation preconditions and fleet guardrails |
| [threat-model.md](threat-model.md) | Assets, trust boundaries and threats; review date 2026-11-12 |
| [approval-enforcement.md](approval-enforcement.md) and [approval-adapter.json](approval-adapter.json) | The approval contract and its seven declared action types, from target inspection to destructive recovery |
| [agent-runtime-safety.md](agent-runtime-safety.md) | Runner-neutral contract for any agent using the skills |
| [control-plane-adoption.md](control-plane-adoption.md) | How this engine is registered in the shared control plane |
| [capability-crosswalk.md](capability-crosswalk.md) | Linux capability families mapped to Windows owners |
| [architecture-decisions/README.md](architecture-decisions/README.md) | Six accepted decisions, reversal triggers and review dates |

## Operations

| Document | What it holds |
|---|---|
| [operations/commands-and-scripts-manual.md](operations/commands-and-scripts-manual.md) | The operator manual for the `wsa-` commands, module functions, the Python CLI and the repository scripts |
| [operations/command-catalog.md](operations/command-catalog.md) | The concise command catalogue |
| [operations/direct-command-tree.md](operations/direct-command-tree.md) | The layout and installation of the `commands/` tree |
| [operations/system-admin-activity.md](operations/system-admin-activity.md) | Activity records written by `WindowsSkills.Engine` |
| [operations/group-policy-pilot.md](operations/group-policy-pilot.md) | Worked plan: a Group Policy change on a pilot OU, then the fleet |
| [operations/file-share-after-patching.md](operations/file-share-after-patching.md) | Worked plan: a file share unreachable after patching, cause unknown |
| [ai-prompting/domain-prompt-compilation-contract.md](ai-prompting/domain-prompt-compilation-contract.md) | The contract for ready-to-paste administration prompts |

## Testing, packaging and release

| Document | What it holds |
|---|---|
| [testing/test-plan.md](testing/test-plan.md) | Risk layers and the 2026-08-12 local results |
| [marketplace.md](marketplace.md) | Claude and Codex plugin checks and the 5,000-file ceiling |
| [release/delivery-evidence-pack.md](release/delivery-evidence-pack.md) | The 0.1 delivery evidence, 2026-08-12 |
| [release/idempotent-installer-2026-08-12.md](release/idempotent-installer-2026-08-12.md) | Evidence for the install, update and repair workflow |
| [release/community-structure-cleanup-2026-08-12.md](release/community-structure-cleanup-2026-08-12.md) | Evidence for the semantic public paths |

## Research and currentness

| Document | What it holds |
|---|---|
| [research/currentness-2026-10-31.md](research/currentness-2026-10-31.md) | Scoped primary-source review of Windows, PowerShell, Hyper-V, Arc, Intune and baselines |
| [research/currentness-2026-10-29.md](research/currentness-2026-10-29.md) | The earlier scoped review |
| [references.md](references.md) | The books, repositories, standards, Microsoft sources and websites the skills cite; moved out of the README |
| [research/source-synthesis.md](research/source-synthesis.md) | Source admission decisions and their consequences |
| [research/book-driven-kaizen-operating-system.md](research/book-driven-kaizen-operating-system.md) | Improvement doctrine synthesised from books; not a source of current commands |
| [research/source-url-verification-2026-08-12.json](research/source-url-verification-2026-08-12.json) | URL liveness results for the source register on 2026-08-12 |

The live source register is `engine/source-register.yaml`. Its date gate fails on a calendar date unless rows are re-verified; the calendar is in the README ([Calendar of date-triggered gates](../README.md#calendar-of-date-triggered-gates), under Quality and improvement).

## Audits

| Document | What it holds |
|---|---|
| [audits/kaizen-baseline-and-95-plan-2026-08-12.md](audits/kaizen-baseline-and-95-plan-2026-08-12.md) | The August baseline scorecard and improvement plan |
| [audits/2026-09-06-kaizen.md](audits/2026-09-06-kaizen.md) | The September kaizen record |
| [audits/2026-09-06-kaizen-independent-review.md](audits/2026-09-06-kaizen-independent-review.md) | Independent review of the fleet-manifest validator at that date |
| [audits/ai-slop-audit-2026-08-12.md](audits/ai-slop-audit-2026-08-12.md) | Anti-slop audit of the 0.1 scope |
| [security/skill-safety-audit-2026-08-12.md](security/skill-safety-audit-2026-08-12.md) | Skill safety audit of the 0.1 boundary |

## Kaizen records

| Folder or document | What it holds |
|---|---|
| [kaizen/2026-10-engine-kaizen/](kaizen/2026-10-engine-kaizen/05-final-report.md) | The 29 October 2026 cycle: scope, baseline, backlog, experiments, validation, [final report](kaizen/2026-10-engine-kaizen/05-final-report.md) and [next cycle](kaizen/2026-10-engine-kaizen/06-next-cycle.md) |
| [kaizen/2026-10-engine-kaizen-pass-2/](kaizen/2026-10-engine-kaizen-pass-2/05-final-report.md) | The 31 October 2026 pass: the same seven files, with the [final report](kaizen/2026-10-engine-kaizen-pass-2/05-final-report.md) and [next cycle](kaizen/2026-10-engine-kaizen-pass-2/06-next-cycle.md) |
| [kaizen/2026-10-engine-kaizen-pass-2/07-docs-followups.md](kaizen/2026-10-engine-kaizen-pass-2/07-docs-followups.md) | Skill, manifest and validator changes the documentation pass found but left alone |
| [kaizen/october-2026-improvements.md](kaizen/october-2026-improvements.md) | The full itemised list of what the October 2026 kaizen improved; the README holds a summary |
| [kaizen/tool-controller-contract.md](kaizen/tool-controller-contract.md) | The typed controller and object-output contract |
| [kaizen/pipeline-binding-review.md](kaizen/pipeline-binding-review.md) | Pipeline binding and trace safety for the service-state controller |

## Plans

[plans/windows-engine/README.md](plans/windows-engine/README.md) is the 21-phase build plan of August 2026. It is a plan, not a status report.

## Related engines

The router and the control-plane documents name sibling engines by their current GitHub names. Three of them were renamed on GitHub while some local checkouts kept the old directory names: `chwezi-dev-engine` (local directory `skills-web-dev`), `chwezi-sdlc-documentation` (`srs-skills`) and `chwezi-design-engine` (`design-system-skills`). The research engine, `linux-skills`, `chwezi-accounting-doctrine` and the coordination package `chwezi-engine-agents` are resolved through the device catalogue, as `AGENTS.md` says. No validator in this repository needs any of them.
