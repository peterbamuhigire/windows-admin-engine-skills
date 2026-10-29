# Practitioner task observations (synthetic/read-only)

Date/access date: 2026-10-29. No production machine, Windows host, domain, share, or service was contacted. Router output was generated locally using `python` and the engine’s `python/windows_admin.router.rank` against the repository catalogue.

## Task 1 — Group Policy pilot OU then fleet

**Prompt:** “Plan a Group Policy change across a pilot OU and then the fleet, and check risk class, preview, canary, verification and rollback are all specified.”

**Route output:**

1. `windows-group-policy`, score 10; reasons `phrase:group policy`, `category:policy`.
2. `windows-fleet-management`, score 8; reasons `token:fleet`, `token:canary`, `category:fleet`.
3. `windows-identity-lifecycle`, score 3; reason `token:group`.

The GPO-first route is appropriate, with fleet management as a supporting skill (inference; based on prompt intent and router evidence). The GPO skill requires an explicitly named domain/OU, authority, preview, backup/replication evidence, test ring, verification and rollback. The prompt supplies no real target, authority, window, approved backup, or recovery owner; therefore the task remains a plan outline, not an executable change record. No command was run.

## Task 2 — Domain-joined clients cannot access a file share after patching

**Prompt:** “Diagnose this failure: domain-joined machines cannot reach a file share after patching. What troubleshooting path is ordered and evidence-first?”

**Route output:**

1. `windows-storage-files-services`, score 3; reason `token:share`.
2. `windows-troubleshooting`, score 2; reason `category:troubleshooting`.

This ordering conflicts with the hub rule “use windows-troubleshooting first when an unexplained symptom spans components” (`skills/windows-sysadmin/SKILL.md`, description at line 3 and route table at line 87). The task is a cross-component symptom with cause not established; top-1 storage route is a likely routing defect (inference). Patching is not represented in the shown route reasons. Expected output should start with evidence gathering and distinguish client network/name resolution, authentication/authorization, SMB/share/NTFS permissions, server service, and post-patch change evidence, but no operational diagnostics were run because environment and authority were not supplied.

## Task 3 — Three WSA commands with `-WhatIf` and an out-of-scope target

**Prompt:** “Run three wsa- commands in -WhatIf mode against a lab fixture, and check the safety boundary refuses an out-of-scope target.”

**Route output:** no route returned by `rank()`.

A disposable `mcr.microsoft.com/powershell` container was used with a synthetic `Get-Service` fixture and a throw-on-call guard for service mutations. Running `commands/storage/services/wsa-service-state.ps1` with named `-Name FixtureSvcA -DesiredState Stopped ... -WhatIf -Confirm:$false` failed at argument validation before a service lookup. Exact error observed: `Cannot validate argument on parameter 'DesiredState'. The argument "FixtureSvcA" does not belong to set Running,Stopped.` (local observation). Wrapper chain: `commands/storage/services/wsa-service-state.ps1:1` delegates with `@args`; `commands/bin/wsa.ps1:2,4` captures an `object[]` then splats it; `commands/_lib/Invoke-WsaCommand.ps1:4,33` repeats the generic array splat into `Invoke-WseServiceState`. A minimal PowerShell parameter-binding reproduction using an array of strings likewise binds `-Name` as a positional value. This is a likely real wrapper defect (inference): named arguments are flattened/lost before the engine function receives them.

No service mutation occurred; the synthetic guard was not reached. I could not complete three command-level `-WhatIf` previews or verify wrapper-level out-of-scope rejection because the wrapper fails first. A separate direct module/Pester probe is NOT_ASSESSED: the temporary Pester fixture used invalid root-level setup and Pester 5.7.1 reported 0 passed / 4 failed; the registered behaviour runner also relies on Windows Principal APIs unavailable in the Linux container. Do not mislabel this as a Windows safety-boundary failure.

**Candidate small defect for later authorized cycle:** replace positional string-array forwarding with parameter-preserving forwarding or a hashtable, then add Windows PowerShell regression tests for (a) named `-Name`/`-DesiredState` binding through wrapper, (b) `-WhatIf` no mutation, and (c) out-of-scope rejection before resource lookup. First validate the intended interface on actual Windows or a supported Windows test runner. No source file was changed in preparation.
