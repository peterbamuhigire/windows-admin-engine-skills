# Community structure cleanup evidence

## Artifact identity

| Field | Value |
|---|---|
| Project | Windows Administration Skills Engine |
| Deliverable | Semantic public paths and community README |
| Owner | Peter Bamuhigire |
| Reviewer | Codex repository checks; human review pending |
| Date | 2026-08-12 |
| Related skills | `skills-web-dev`, `anti-ai-slop`, `sdlc-documentation`, `ai-slop-audit` |

## Decision record

| Decision | Rationale | Alternative rejected | Reversal trigger |
|---|---|---|---|
| Place procedures under `skills/<domain>/` and commands under `commands/<domain>/` | Domain names remain meaningful as the catalogue grows and do not expose internal build phases | Retaining top-level phases 09–18 required readers to discover why 01–08 were absent | Reopen if a published runner requires a different fixed path contract |
| Keep 01–21 numbering only in `docs/plans/windows-engine/` | The numbers describe an actual historical sequence there | Removing all phase numbers would erase useful implementation history | Reopen if the plan is superseded and archived elsewhere |
| Treat `engine/catalog.yaml` as the skill-path source of truth | Existing routing and validation already consume it | Maintaining compatibility aliases would preserve the confusing root layout | Add an explicit migration layer only if an external consumer reports a concrete need |

## Contract evidence

| Contract | Evidence | Result |
|---|---|---|
| Skill catalogue | 16 catalogue entries resolve below `skills/` | PASS |
| Hub route | `skills/windows-sysadmin/SKILL.md` exists and its local links resolve | PASS |
| Command catalogue | Generated from 48 launchers under semantic command categories | PASS |
| Structure guardrail | Validator rejects numbered public root directories and skills outside `skills/` | PASS |
| Package licence metadata | `pyproject.toml` now matches the repository's GPL-3.0 licence file | PASS |

## Test evidence

| Check | Result |
|---|---|
| `scripts/validate_engine.py` | 16 skills, 0 findings |
| `scripts/routing_smoke_test.py` | 16 fixtures, 0 failures |
| `scripts/source_ingestion_guardrail.py` | 0 findings |
| `scripts/validate_command_tree.py` | 48 commands, 0 findings |
| `scripts/validate_operator_manual.py` | 48 commands, 14 scripts, 10 functions, 0 findings |
| Fleet manifest validation | 1 target, 0 findings, no contact attempted |
| Python unit tests | 10 passed |
| PowerShell syntax gate | 70 files, 0 findings |
| Pester module contract | 3 passed, 0 failed |
| PowerShell smoke | inventory succeeded; service mutation remained preview-only |
| Installer preview | 51 directories, 49 command names, 0 collisions; `-WhatIf` made no environment change |
| Moved command smoke | `commands/engine/catalog/wsa-list.ps1` listed all 16 skills |

## Operational evidence

No target mutation, reboot, remote connection, policy change, or destructive
operation was authorised or performed. The only service-control exercise used
`-WhatIf` against the local EventLog service. Rollback is the ordinary Git
revert of the path, catalogue, validator, and documentation changes.

Windows Server, domain-controller, Hyper-V, remote WinRM, PowerShell 7, and
non-English-locale behaviour remain `NOT_ASSESSED`. This structure change does
not promote any platform or mutation maturity row.

## Anti-slop gate

Verdict: A (clean). Genericness score: 7/100, based on a manual written-content
rubric. The README names concrete commands, paths, counts, risk boundaries, and
unassessed platforms; it contains no placeholders, fabricated citations, or
unsupported production-readiness claim. Automated phrase and local-link scans
reported no blocking finding.

## Release verdict

| Gate | Verdict | Note |
|---|---|---|
| Structure | PASS | Public paths are semantic and validator-enforced |
| Safety | PASS | No operational authority boundary changed |
| Tests | PASS | All locally available static, unit, syntax, Pester, and smoke gates passed |
| Documentation | PASS | README covers setup, routing, architecture, safety, validation, and contribution |
| Live server labs | NOT_ASSESSED | Unchanged from the platform matrix |

Final decision: ready for human review and community publication.
