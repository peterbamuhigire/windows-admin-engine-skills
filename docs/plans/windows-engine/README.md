# Windows Administration Skills Engine — 21-Phase Build Plan

Status: implementation plan; no feature implementation is authorised by this document alone.
Prepared: 11 August 2026
Repository: C:\wamp64\www\windows-admin-engine-skills
Reference engine: C:\wamp64\www\linux-skills

## Outcome

Build a portable, evidence-driven Windows system and network administration engine that an operator or AI agent can use from the command line. The engine will contain:

- a small Windows administration router;
- self-contained specialist skills;
- a signed and testable PowerShell module for native Windows control;
- Python utilities for orchestration, inventory normalisation, reporting, API integration, and cross-host analysis;
- a shared scripts directory installed into the operator's CLI path;
- safe read-only discovery before mutation;
- explicit target, privilege, approval, reboot, outage, lockout, rollback, and evidence contracts; and
- disposable Windows labs that prove claimed behaviour.

The goal is not a giant command encyclopedia or a promise to automate every Windows product. The goal is trustworthy coverage: the engine must identify what it knows, what it can safely do, what it has actually verified, and where it must stop.

## Design decision: Windows native first, Python complementary

PowerShell is the primary implementation language for Windows-native operations because Windows management surfaces expose PowerShell, CIM/WMI, remoting, registry, eventing, security, and role modules directly. Python is the supporting language for:

- cross-host orchestration and concurrency control;
- evidence and inventory normalisation;
- report generation and data quality checks;
- REST/Graph/Windows Admin Center/Azure adapters where an API is the correct boundary;
- parsers, schema validators, fixture tooling, and test harnesses; and
- integrations that must also run from Linux or CI.

Do not implement the same privileged mutation twice. Choose one canonical owner and let the other language call the approved boundary.

## Linux parity audit

The Windows engine should reproduce the Linux engine's operational coverage, not its commands:

| Linux capability family | Windows counterpart |
|---|---|
| Provisioning and bootstrap | Windows installation, imaging, Server Core, roles/features, WinGet, drivers, first-boot and management bootstrap |
| Users, access, secrets | Local accounts, AD DS, Entra identity boundaries, groups, LAPS, JEA, certificates, Credential Manager and secret stores |
| Networking and DNS | IP configuration, routes, firewall, WinRM, RDP, DNS, DHCP, VPN, SMB, proxy, certificates and name-resolution diagnostics |
| Web and mail services | IIS, HTTP.sys, certificates, URL ACLs, SMTP/API handoffs; Exchange is a separate supported product boundary |
| Services and virtualisation | Windows services, scheduled tasks, Hyper-V, Failover Clustering, Windows containers and WSL |
| Storage and filesystems | NTFS, ReFS, SMB, DFS, Storage Spaces, quotas, deduplication, volumes, shares, ACLs and file locking |
| Security and hardening | Defender, firewall, BitLocker, AppLocker/WDAC, security policy, audit policy, baselines, attack-surface reduction and vulnerability evidence |
| Observability and logs | Event Log, ETW, PerfMon, WPR/WPA, dump collection, Windows Admin Center and structured health snapshots |
| Troubleshooting and recovery | SFC/DISM, WinRE, safe mode boundaries, service recovery, AD/DNS recovery, backup restore and incident evidence |
| Automation and scripting | PowerShell, Python, DSC, Pester, PSScriptAnalyzer, scheduled execution, remoting and reusable command shims |
| Databases and caching | SQL Server, PostgreSQL, MySQL, Redis and application-owned adapters; database doctrine remains with the database skill |
| Containers and orchestration | Windows containers, Docker/Containerd, WSL2, Hyper-V isolation and Kubernetes handoffs |
| Backup and archiving | Windows Server Backup, VSS, Hyper-V checkpoints with cautions, Storage Replica, Azure Backup and file/database restore |
| Performance and kernel | CPU, memory, I/O, storage, networking, ETW traces, counters, driver evidence, WinDbg and controlled tuning |
| Compliance and auditing | Microsoft SCT, CIS/STIG/NIST crosswalks, configuration drift, audit evidence and exceptions |

## Engine topology

~~~text
operator or AI request
        |
        v
windows-sysadmin router
        |
        +--> specialist SKILL.md
        |        |
        |        +--> manual workflow and decision rules
        |        +--> curated references and source register
        |        +--> PowerShell accelerator
        |        +--> Python adapter or report tool
        |
        v
WindowsSkills.Engine safety and evidence module
        |
        v
target resolver -> operation -> verification -> evidence pack -> release verdict
~~~

## Proposed repository shape

~~~text
AGENTS.md
README.md
windows-sysadmin/SKILL.md
meta/{powershell-engineering,python-automation,skill-writing,skill-safety-audit}/
01-*/.../SKILL.md
engine/{catalog.yaml,catalog.schema.json,platform-matrix.yaml,source-register.yaml}
powershell/WindowsSkills.Engine/{Public,Private,Classes,Tests}
python/windows_admin/{cli,collectors,normalizers,reporting,adapters}
scripts/{windows-admin.ps1,windows-admin.cmd,install-windows-admin.ps1,...}
templates/{skill,evidence-pack,change-plan,rollback-plan,lab-fixture}
tests/{static,unit,contract,integration,lab,negative,fixtures}
labs/{hyper-v,domain,workgroup,server-core,client,hybrid}
docs/{architecture-decisions,quality-gates,threat-model,plans}
~~~

## Non-negotiable contracts

Every specialist skill must define trigger, exclusions, inputs, target identity, platform matrix, privilege boundary, discovery, mutation, verification, rollback, reboot/disconnect risk, evidence, source freshness, and positive/negative/second-run examples.

Every script or module operation returns a versioned object with at least:

~~~text
SchemaVersion, OperationId, Command, Target, IdentityContext, Status,
Changed, RebootRequired, DisconnectRisk, StartedAt, FinishedAt,
Before, After, Verification, RollbackArtifact, EvidencePath, Errors, Warnings
~~~

Allowed statuses are NoChange, Succeeded, Failed, PendingReboot, PartiallySucceeded, and Aborted.

R0 read-only work requires target resolution, redaction, and evidence. R1 reversible local changes require ShouldProcess, before/after state, and rollback. R2 service-impacting work requires maintenance context and health checks. R3 access or disconnection risk requires timed recovery or out-of-band access. R4 identity/security-boundary changes require peer review and staged rollout. R5 destructive or hard-to-reverse work requires backup proof, typed decision, and explicit change authority.

## 21-phase map

1. Charter, mission, and threat model
2. Linux parity audit and Windows capability map
3. Research, source governance, and book extraction
4. Control plane, catalog, and skill contracts
5. Platform matrix and support policy
6. Safety, target authority, and change control
7. PowerShell/Python toolchain foundation
8. Shared execution, evidence, and rollback primitives
9. Inventory, health, and diagnostics
10. Networking and remote management
11. Identity, Active Directory, and access
12. Policy, security, and compliance
13. Patching, software, and endpoint management
14. Storage, files, services, and web workloads
15. Virtualisation, containers, and development environments
16. Observability, performance, and troubleshooting
17. Backup, recovery, and business continuity
18. Fleet, hybrid, and management planes
19. Labs, CI, and validation
20. Packaging, CLI distribution, and operator experience
21. Production launch, Kaizen, and portfolio growth

Each phase directory contains purpose, scope, workstreams, artifacts, tests, dependencies, risks, and a hard exit gate. Phase gates are evidence gates: documents alone do not promote a capability.

## Current-source anchors

These are starting points for the source register, not permission to copy documentation:

- Microsoft Windows Server management overview: https://learn.microsoft.com/en-us/windows-server/administration/overview
- Windows Admin Center overview: https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview
- Microsoft PowerShell documentation: https://learn.microsoft.com/en-us/powershell/
- PowerShell remoting and JEA: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/prerequisites
- Microsoft DSC 3.0 overview: https://learn.microsoft.com/en-us/powershell/dsc/overview
- Microsoft Security Compliance Toolkit: https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10
- Sysinternals official resources: https://learn.microsoft.com/en-us/sysinternals/
- PSScriptAnalyzer: https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview
- Pester: https://pester.dev/

These sources establish current product boundaries and verification leads. A book or blog never overrides current product documentation or lab evidence.

## Portfolio rules

- Keep licensed books and restricted source files outside Git.
- Preserve source provenance, edition, access rights, scope, and freshness.
- Do not reproduce book text, large extracts, benchmark content, Microsoft binaries, or vendor installers.
- Never store secrets, recovery keys, LAPS passwords, private keys, tokens, or raw sensitive directory exports in fixtures or evidence.
- Read-only discovery is the default for agents and scripts.
- Production mutation, elevation, reboot, firewall lockout risk, identity changes, destructive storage work, and external publication require explicit authority.
- Every failure becomes a defect with target, operation, evidence, severity, owner, repair, and retest.
- Apply Kaizen at two levels: improve this engine, then improve each Windows environment and product it manages.
- Publish initial audits at no more than 65/100 and plan evidence-backed improvement toward 95/100; never invent a score from repository size.
