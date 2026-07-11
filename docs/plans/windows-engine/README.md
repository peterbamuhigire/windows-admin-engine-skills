# Windows Skills Engine — implementation plan

**Status:** Planning baseline; implementation is intentionally deferred  
**Prepared:** 11 July 2026  
**Repository:** `windows-admin-engine-skills`  
**Primary input:** `C:\Users\Peter\Downloads\windows-skills-engine-blueprint.md`

## 1. Outcome

Build a portable, evidence-driven Windows administration skills engine that can guide an AI agent or human operator through Windows Server and Windows 11 work with Microsoft-calibre discipline. The engine will combine concise specialist skills, authoritative references, safe PowerShell accelerators, explicit risk contracts, and proof from disposable Windows labs.

The first production release is successful when it can route, execute, verify, and explain a small set of common administrative workflows more safely and consistently than an unstructured expert prompt. Skill count is not the goal. Trustworthy completion evidence is.

## 2. Decisions inherited from the blueprint

The plan adopts these design choices unless an architecture decision record (ADR) later changes them:

- Use a small `windows-sysadmin` router and narrow specialist skills.
- Keep each `SKILL.md` portable and manually executable; scripts are optional accelerators.
- Use `engine/catalog.yaml` as the authoritative inventory and generate duplicate views.
- Make structured PowerShell objects the default automation output.
- Make reboot, service impact, remote disconnection, privilege, and rollback explicit contracts.
- Require discovery before mutation and post-change verification after mutation.
- Build one shared `WindowsSkills.Engine` PowerShell module for common safety behaviour.
- Validate platform claims in disposable Windows labs; mocks alone never earn `validated` status.
- Start with Windows Server 2022/2025 and Windows 11; treat Server 2019 as a compatibility target and Server 2016 as best effort until tested.
- Support Windows PowerShell 5.1 where inbox modules require it and prefer PowerShell 7 for new tooling.
- Separate collection from remediation, especially for security and compliance skills.

## 3. Product boundaries

### In scope for the first major release

- Local and remote Windows Server inventory, health, networking, event logs, baseline assessment, services, firewall, patching, IIS, backup, and read-only Active Directory health.
- Windows 11 administration where needed for management workstations and developer environments.
- WinRM, CIM sessions, and carefully bounded PowerShell-over-SSH workflows.
- Server Core and Desktop Experience where the underlying role supports both.
- Workgroup, member-server, domain-controller, and management-workstation identities as explicit contexts.
- Evidence packs, offline operation, source freshness, and signed release artifacts.

### Deferred until the control plane is proven

- Destructive forest recovery automation, production CA changes, storage reformatting, broad tenant-wide Intune changes, and autonomous incident containment.
- Claims of support for every System Center, Azure, Arc, Intune, cluster, or third-party product combination.
- A graphical management application.
- Bundling third-party binaries or copyrighted books without redistribution permission.

### Explicit non-goals

- A line-for-line Windows translation of `linux-skills`.
- A giant command encyclopedia.
- An agent that silently elevates privilege, reboots machines, disables security controls, or chooses production targets.
- Replacing Microsoft documentation, vendor support, change control, or an experienced incident commander.

## 4. Architecture

```text
operator request
      |
      v
windows-sysadmin router -----> specialist SKILL.md
                                  |       |
                                  |       +--> curated references and decision aids
                                  v
                         manual workflow / PowerShell accelerator
                                  |
                                  v
                     WindowsSkills.Engine safety services
                                  |
                                  v
                    target + verification + evidence pack
```

The repository should converge on:

```text
AGENTS.md
README.md
windows-sysadmin/SKILL.md
meta/{powershell-engineering,skill-writing,skill-safety-audit}/
skills/<category>/<skill-name>/SKILL.md
engine/{catalog.yaml,catalog.schema.json,platform-matrix.yaml,source-register.yaml}
powershell/WindowsSkills.Engine/{Public,Private,Classes,WindowsSkills.Engine.psd1}
templates/{evidence-pack,change-plan,rollback-plan,jea}/
tests/{static,unit,contract,integration,lab,negative,fixtures}/
labs/{hyper-v,domain,workgroup,azure}/
scripts/{Test-EngineConformance.ps1,Test-Catalog.ps1,Build-Docs.ps1}
docs/{architecture-decisions,engine-design,quality-gates,threat-model,plans}
```

Skills should remain shallow and discoverable. Detailed references sit one link away from the owning `SKILL.md`. The engine catalog stores machine facts; Markdown explains intent and workflow.

## 5. Mandatory contracts

### Skill contract

Every specialist must define:

1. trigger description using realistic operator language;
2. exclusions and handoffs;
3. required inputs and explicit target identity;
4. platform support matrix;
5. risk class and approval boundary;
6. discovery workflow;
7. change workflow, when applicable;
8. verification and completion evidence;
9. rollback or an honest statement that rollback is unavailable;
10. reboot, service-impact, and disconnect behaviour;
11. inputs and outputs with stable artifact types;
12. authoritative sources, review date, and known gaps;
13. positive, negative, and second-run acceptance examples.

### Operation contract

All accelerator commands return a stable envelope containing at least:

`SchemaVersion`, `OperationId`, `Command`, `Target`, `Status`, `Changed`, `RebootRequired`, `DisconnectRisk`, `StartedAt`, `FinishedAt`, `Before`, `After`, `Verification`, `RollbackArtifact`, `EvidencePath`, `Errors`, and `Warnings`.

Allowed status values are `NoChange`, `Succeeded`, `Failed`, `PendingReboot`, `PartiallySucceeded`, and `Aborted`. Domain-specific records belong inside the envelope rather than being flattened into generic text.

### Risk contract

| Class | Meaning | Minimum gate |
|---|---|---|
| R0 | read-only observation | explicit target, redaction, evidence |
| R1 | locally reversible change | `ShouldProcess`, before/after state, rollback |
| R2 | service impact | maintenance context, health check, rollback |
| R3 | access/disconnection risk | out-of-band or timed rollback, explicit approval |
| R4 | identity/security boundary | peer review, staged ring, complete evidence |
| R5 | destructive or hard to reverse | named target, backup proof, typed decision, change record |

No generic confirmation can supply a missing consequential decision. A command must fail closed when target, impact, recovery path, or authority is ambiguous.

### Evidence contract

An evidence pack records the environment fingerprint, engine/catalog version, sanitized command intent and parameters, before state, intended state, after state, verification, relevant log/event references, rollback artifacts, reboot state, hashes, and failures. Secrets, LAPS passwords, private keys, tokens, recovery keys, and sensitive directory attributes must never enter the pack.

## 6. Delivery phases

Each phase ends with a decision gate. Work does not advance because documents exist; it advances when exit evidence passes review.

### Phase 0 — charter, decisions, and research corpus (2–3 weeks)

**Purpose:** remove foundational ambiguity before code or dozens of skills are created.

Work:

- Confirm repository name, license, owners, contribution model, target operators, and initial threat assumptions.
- Write ADRs for platform support, PowerShell editions, remoting transports, policy ownership, evidence retention, signing, lab topology, catalog format, and maturity model.
- Define ten real MVP scenarios and 40–60 routing utterances, including ambiguous and unsafe requests.
- Establish the research source register and licensed-material intake process described in [reading-and-extraction-plan.md](reading-and-extraction-plan.md).
- Inventory official Microsoft documentation, release lifecycles, Security Compliance Toolkit baselines, protocol specifications, Pester/PSScriptAnalyzer documentation, and relevant CIS material.
- Record source licensing, version/build scope, volatility, review owner, last reviewed date, and review due date.
- Create the initial glossary: target, identity context, management plane, policy owner, desired state, evidence pack, rollback, pending reboot, disconnection risk, maturity, and validation.

Deliverables:

- project charter;
- ADR backlog with at least the ten blueprint decisions resolved;
- scoped source register;
- MVP scenario set and routing benchmark;
- risk register and initial threat model;
- material acquisition list with priorities and budgets to be approved by Peter.

Exit gate:

- No unresolved decision can change the repository topology or MVP platform promise.
- Every load-bearing architectural claim has a source or is marked as an explicit design decision.
- Purchased/downloaded materials have provenance and usage rights recorded.
- Peter approves the MVP scenarios and platform promise.

### Phase 1 — engine control plane (3–4 weeks)

**Purpose:** build the rules that keep later skills consistent.

Work:

- Create repository-level `AGENTS.md` and the `windows-sysadmin` routing hub.
- Define `catalog.schema.json`, `catalog.yaml`, `platform-matrix.yaml`, and `source-register.yaml`.
- Define maturity states: `planned`, `draft`, `experimental`, `lab-validated`, `production-validated`, `deprecated`.
- Create the three meta-skills: `powershell-engineering`, `skill-writing`, and `skill-safety-audit`.
- Create canonical templates for skills, references, evidence packs, change plans, rollback plans, ADRs, source notes, exemplars, and test manifests.
- Implement static conformance checks for naming, frontmatter, mandatory sections, links, orphaned catalog entries, unsupported maturity claims, source freshness, secrets, and forbidden PowerShell patterns.
- Generate README/catalog views from machine-readable data and require a clean regeneration diff.

Deliverables:

- working router skeleton;
- validated catalog/schema;
- authoring and safety meta-skills;
- conformance command and CI workflow;
- versioned artifact schemas.

Exit gate:

- A deliberately malformed sample fails every applicable gate.
- A reference sample skill passes deterministically on Windows PowerShell 5.1 and PowerShell 7 where claimed.
- Generated documentation is reproducible.
- Catalog data is never manually duplicated as another source of truth.

### Phase 2 — shared PowerShell safety module (4–6 weeks)

**Purpose:** prove common operational behaviour once.

Implement and document, in small increments:

- platform and edition detection;
- target resolution and elevation/privilege assertions;
- operation lifecycle and correlation IDs;
- stable result envelope and schema versioning;
- safe native-process invocation and exit-code mapping;
- redaction and sensitive-value tests;
- normalized before/after state and drift comparison;
- rollback registration and artifact hashing;
- pending-reboot detection with reason codes;
- disconnection-risk classification;
- WinRM/CIM remote execution with throttling and per-host partial results;
- evidence-pack export;
- restart readiness probes without implicit restart.

Engineering rules:

- approved verbs and singular nouns;
- strongly typed and validated parameters;
- `SupportsShouldProcess` for mutation;
- no `Invoke-Expression`;
- objects on the success stream and correct diagnostic streams;
- no plaintext credentials or secrets in arguments, transcripts, output, or fixtures;
- no silent elevation or privilege widening;
- explicit 32/64-bit registry and executable view;
- pinned dependencies and declared edition compatibility.

Exit gate:

- Pester unit and contract suites pass on PowerShell 7 and the claimed 5.1 subset.
- `-WhatIf`, redaction, idempotency primitives, native failures, partial fleet failures, pending reboot, and disconnection risk all have negative tests.
- The module can produce a validated sample evidence pack without touching a real production system.

### Phase 3 — read-only MVP skills (6–8 weeks)

Build in this order:

1. `windows-system-inventory`;
2. `windows-health-assessment`;
3. `windows-network-admin`;
4. `windows-event-logs`;
5. `windows-security-analysis`;
6. `windows-active-directory` read-only health.

For each skill:

- start from ten real request examples;
- define responsibility and handoffs before writing procedures;
- build the manual procedure first;
- add platform, identity, remoting, and privilege matrices;
- create structured artifact schemas and sanitized exemplars;
- add an accelerator only when it removes repeat work or produces more reliable evidence;
- test local, remote, inaccessible, unsupported, least-privilege, and partial-result cases;
- run independent forward tests using clean task context;
- promote maturity only after stored lab evidence exists.

Exit gate:

- Routing benchmark reaches at least 90% correct specialist selection and 100% safe escalation on the dangerous subset.
- All six skills work manually without the module installed.
- All accelerator outputs validate against their schemas.
- Every claimed platform has a sanitized lab evidence pack.
- Security assessment remains read-only and does not imply authorization to remediate.

### Phase 4 — safe mutation MVP (8–12 weeks)

Build:

1. `windows-service-management`;
2. `windows-firewall`;
3. `windows-update-management`;
4. `windows-iis`;
5. `windows-local-users-groups`;
6. `windows-backup`.

Every mutation must demonstrate:

- valid discovery and ownership checks before change;
- `-WhatIf` causes no change;
- consequential decisions cannot be inferred;
- already-compliant state returns `NoChange`;
- pre-change capture, actual-state re-query, and role-aware health verification;
- rollback rehearsal or a documented non-reversible boundary;
- correct service/reboot/disconnection reporting;
- secret-safe evidence;
- safe refusal under insufficient privilege or unsupported context.

Exit gate:

- Positive, negative, idempotent second-run, rollback, and interrupted-operation tests pass.
- Firewall remote-safety tests prove timed rollback or out-of-band prerequisites.
- Update tests validate the full restart lifecycle and post-reboot service readiness.
- Backup tests prove restore, not merely backup creation.

### Phase 5 — enterprise identity, policy, and core infrastructure (10–16 weeks)

Add bounded skills for AD object lifecycle, replication and trusts, Group Policy, DNS, DHCP, Windows LAPS, JEA/privileged access, PKI/AD CS assessment, Defender, BitLocker, application control, security baselines, file services, DFS, Hyper-V, and failover clustering.

Build the isolated multi-machine Hyper-V lab:

- `DC1`: Windows Server 2025 AD DS/DNS;
- `DC2`: additional domain controller;
- `MEM1`: Server Core member;
- `WEB1`: IIS member;
- `FILE1`: file/DFS role;
- `CL1`: Windows 11 client;
- `MGMT1`: PowerShell 7 management workstation;
- optional isolated DHCP, PKI, and cluster nodes as their skills enter validation.

Required exercises include replication failure, duplicate SPN, time skew, broken secure channel, GPO precedence, DNS aging, DHCP failover, expired certificate, inaccessible host, locked file, policy conflict, cluster role movement, and lost remote session.

Exit gate:

- Tier-0 and identity-boundary mutations require peer-review artifacts and staged deployment.
- AD, GPO, PKI, and cluster claims are supported by multi-machine evidence rather than mocks.
- Recovery drills restore service and preserve evidence.

### Phase 6 — workstation, development, hybrid, and fleet packs (8–12 weeks)

Add Windows 11 management, reproducible development environments, .NET, Python, Node.js, C/C++, IIS/local web stacks, WSL, containers, Azure Arc, Intune, Defender for Cloud, and fleet fan-out/resume capabilities.

Keep the management planes separate. A GPO-controlled value must not be repeatedly changed by a local script; an Intune, DSC, ConfigMgr, application, or cloud policy owner must be detected and reported.

Exit gate:

- Workstation packs are separable from server installations.
- Fleet operations retain per-host outcomes, bounded concurrency, resumability, and cancellation.
- Hybrid skills identify tenant/subscription/context explicitly and do not cross cloud boundaries by inference.

### Phase 7 — production release and operating model (4–6 weeks)

Work:

- sign release commits, tags, PowerShell modules, and installer artifacts;
- create online and offline bundles with SHA-256 manifests;
- implement install, update, repair, test, and uninstall workflows;
- pin dependencies and refuse modified-file overwrite;
- establish evidence classification, retention, and disposal;
- run source-freshness, prompt-injection, secret, supply-chain, and release reproducibility audits;
- publish sanitized exemplars and operator onboarding;
- rehearse compromised dependency, expired signing certificate, broken update, and rollback scenarios.

Exit gate:

- Clean machines can verify and install an offline signed bundle.
- Repair and uninstall preserve user-owned content.
- Release manifest maps every skill and command to test and validation evidence.
- Critical source freshness is 100%; secret findings are zero.

### Phase 8 — continuous improvement (ongoing)

- Review volatile sources at 30/90/180-day cadences by topic.
- Revalidate against Windows cumulative updates and new Windows/PowerShell releases.
- Add skills only when repeated tasks justify them.
- Triage operator failures into router, reference, script, safety, or platform defects.
- Run quarterly recovery drills and annual threat-model refreshes.
- Deprecate stale workflows with migration guidance; never silently repurpose a skill name.

## 7. MVP acceptance scenarios

The final set is approved in Phase 0. Seed scenarios are:

1. Inventory one Server Core host and explain unsupported collectors.
2. Inventory 50 mixed hosts with unreachable and access-denied nodes.
3. Diagnose a name-resolution versus TCP reachability failure without changing state.
4. Produce a role-aware health report with pending-reboot status.
5. Query relevant event logs with timestamps, channels, provider, and bookmark evidence.
6. Compare a member server to the correct Microsoft security baseline without remediation.
7. Assess AD replication, DNS registration, time, and FSMO reachability read-only.
8. Restart an unhealthy service only after dependency and workload checks.
9. Add a firewall rule remotely with a tested access-preservation path and rollback.
10. Apply Windows updates with explicit reboot choice and role-specific readiness verification.

Every scenario has a manual path, optional accelerator, expected object schema, unsafe variants, and completion evidence.

## 8. Testing and validation matrix

| Layer | Purpose | Required evidence |
|---|---|---|
| static | schema, naming, links, source freshness, forbidden patterns | CI results |
| unit | pure logic and error mapping | Pester XML + coverage |
| contract | `ShouldProcess`, schema, redaction, idempotency | command-level evidence |
| integration | actual Windows APIs on disposable hosts | host fingerprint + result |
| multi-machine | AD, DNS, GPO, remoting, clustering | topology + scenario evidence |
| recovery | rollback and restore correctness | before/failure/recovery/after |
| live validation | claimed platform behaviour | sanitized signed evidence pack |
| forward test | skill usability with clean context | prompt, output, grader notes |

Promotion rules:

- `draft` requires author review.
- `experimental` requires static, unit, and contract evidence.
- `lab-validated` requires applicable disposable/multi-machine evidence on every claimed platform.
- `production-validated` requires a controlled real-environment run, named reviewer, expiry date, and no unresolved high-risk defect.

## 9. Governance and ownership

Suggested roles, even if one person initially holds several:

- product owner: scope and priorities;
- engine architect: contracts and ADRs;
- Windows domain owner: technical correctness;
- PowerShell maintainer: shared module and engineering rules;
- security reviewer: threat model, high-risk workflows, secrets, signing;
- research librarian: source register, acquisition, extraction, freshness;
- lab/release owner: images, test evidence, bundles, promotion;
- skill owner: correctness and review cadence for each package.

Changes to risk taxonomy, result envelope, catalog schema, signing, evidence redaction, or supported platforms require an ADR and migration plan.

## 10. Measures that matter

- routing accuracy and dangerous-request escalation rate;
- skills with complete, validated platform matrices;
- mutating commands passing `WhatIf`, idempotency, negative, and rollback tests;
- live validation coverage by OS, edition, role, and PowerShell edition;
- escaped secrets: target zero;
- successful restore/recovery rate in drills;
- documentation freshness by risk tier;
- evidence-pack completeness and generation time;
- fleet partial-failure accuracy;
- manual workflow completion without accelerators;
- defects found after maturity promotion and mean time to correct them.

Do not use number of skills, scripts, or lines of PowerShell as headline success measures.

## 11. Principal risks and controls

| Risk | Control |
|---|---|
| unsafe remote lockout | R3 contract, console/timed rollback, negative lab tests |
| stale platform advice | source owners, review dates, CI freshness failures |
| secrets in evidence | denylist plus structured redaction and fixture tests |
| false support claims | platform-specific lab evidence required for promotion |
| policy conflict | detect GPO/MDM/DSC/application ownership before mutation |
| abstraction hides Windows semantics | preserve provider-specific behaviour inside domain skills |
| overlarge agent context | concise skills, one-level references, router handoff |
| copyrighted corpus leakage | licensed intake, paraphrased extraction, no chapter mirroring |
| supply-chain compromise | pinned sources, hashes, signatures, offline bundles, review |
| lab contaminates host/network | isolated switches, disposable disks, explicit lab identity |
| automation outruns manual understanding | manual truth required before accelerator |

## 12. First implementation backlog

When implementation begins, execute in this order:

1. approve Phase 0 ADR questions and MVP scenarios;
2. create source register and acquisition ledger;
3. write catalog and artifact schemas;
4. build the router benchmark before the router;
5. create meta-skills and conformance checks;
6. build the shared result envelope, operation lifecycle, and redaction;
7. build `Get-WsePlatform`, target resolution, native invocation, and evidence export;
8. build system inventory as the reference vertical slice;
9. validate the vertical slice on Server 2022, Server 2025 Core/Desktop as applicable, and Windows 11;
10. review the architecture using the evidence from that slice before multiplying skills.

## 13. Planning completion checklist

- [x] Blueprint reviewed and its major decisions incorporated.
- [x] Phased delivery roadmap defined with exit gates.
- [x] MVP skills and acceptance scenarios proposed.
- [x] Risk, evidence, testing, maturity, and governance models defined.
- [x] Reading acquisition and extraction plan created.
- [ ] Peter approves the initial platform promise.
- [ ] Peter approves the first ten acceptance scenarios.
- [ ] Peter approves a reading-material budget and preferred eBook formats.
- [ ] Phase 0 ADRs are written and decided.

