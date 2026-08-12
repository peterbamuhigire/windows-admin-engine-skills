# Kaizen baseline and improvement plan

Product: Windows Administration Skills Engine 0.1  
Audience: authorised Windows operators and agent runners  
Re-audit date: 2026-11-12  
Evidence owner: Peter Bamuhigire; independent technical owners remain unassigned

## Baseline scorecard

| Dimension | Raw /100 | Evidence | Deficiency |
|---|---:|---|---|
| Doctrine | 82 | AGENTS, safety model, threat model, ADRs | Production role owners unassigned |
| Taxonomy and routing | 84 | 16 catalogue skills; 16/16 fixtures | Broader product adapters remain grouped |
| Skill depth | 78 | Portable contracts; external validator 18/18 | Few worked live examples |
| Applied proof | 50 | Local inventory, preview, eight Python and three Pester tests | No Server/AD/fleet/recovery lab |
| Standards currency | 72 | 46 records; 36/36 URLs reachable; historical labels | Semantic claim support still needs lab/manual review |
| Output readiness | 64 | Operation/evidence/fleet schemas and 48 commands | Reports and rollback registry are partial |
| Accessibility and inclusion | 42 | Object output and locale stop rules | Non-English locale untested; no rendered UI |
| Production and handoff | 46 | Installer preview, CI, docs, uninstall | Unsigned; no package/SBOM/canary |
| Hygiene | 86 | Zero source/command/diff findings | Pre-existing plan worktree needs owner review |
| Safety and integrity | 76 | Risk classes, local-only target resolver, safety audit | Redaction and R3-R5 recovery unproved live |

Raw average: 68.0/100.  
Published score: `min(68.0, 65) = 65/100`.

The cap does not override blockers: unsigned distribution, unassigned production
owners, absent PSScriptAnalyzer, and untested Windows Server, AD, remoting,
recovery, and fleet mutations prevent production launch.

## Implemented improvement experiment

| Field | Record |
|---|---|
| Observed waste | AI sessions would be consumed for repeatable read-only tasks |
| Root cause | The plan lacked a dense direct command surface |
| Change | Added 48 `wsa-*` scripts by category/subcategory, `.cmd` launchers, dispatcher, catalogue, scanner, and recursive PATH installer |
| Hypothesis | Common checks run without model routing while retaining shared safety/evidence code |
| Measure | 48 direct commands; one controlled mutation; zero command findings; installer preview 51 dirs/49 names/no collision |
| Risk and rollback | PATH collision/length; preview, collision refusal, deduplication, and scoped uninstall |
| Result | Structural/local checks passed; actual user PATH mutation was not performed |

The experiment is standardised in `commands/`, `engine/command-catalog.json`,
the operator command catalogue, validators, tests, and CI.

## Backlog targeting 95/100

| Priority | Gap/root cause | Change and hypothesis | Owner/due | Acceptance evidence | Risk/rollback |
|---|---|---|---|---|---|
| P0 | No Windows Server/AD proof | Build isolated Server 2025/2022 two-DC and Server Core labs | Lab owner / 2026-09-30 | AD DNS/time/replication/GPO/LAPS negative, second-run, recovery logs | licensed images; reset snapshots |
| P0 | R3-R5 recovery unproved | Test remoting lockout, GPO, identity, storage, and restore failures | Security + lab / 2026-10-15 | timed rollback, out-of-band, clean restore, per-target evidence | isolated networks; abort thresholds |
| P0 | Unsigned/unscanned release | Add signing, PSScriptAnalyzer, secret/dependency scan, SBOM, reproducible package | Release owner / 2026-09-15 | signatures, hashes, scan logs, identical digest | preserve unsigned dev channel |
| P1 | Management adapters absent | Add read-only WAC/Intune/Arc/Graph probes and mixed lab | Fleet owner / 2026-10-31 | rate-limit/auth/tenant/partial-failure tests | no mutation until canary |
| P1 | Locale/runtime gaps | Test PowerShell 7, non-English locale, registry views, non-admin, remote | QA owner / 2026-10-15 | platform matrix evidence | retain unsupported rows |
| P1 | Evidence assurance partial | Add synthetic secret, tamper, duplicate ID, cancellation, rollback-failure tests | Security owner / 2026-09-30 | negative fixtures and failing-on-tamper CI | quarantine bad packs |
| P2 | Operator outcome evidence absent | Run supervised command usability trial | Product owner / 2026-11-12 | time-to-evidence, discovery errors, feedback | dispatcher remains fallback |

The target is 95/100 only after this evidence exists. The next experiment is the
two-DC lab because it unlocks the largest high-risk domain without adding skills.
