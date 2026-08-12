# Source synthesis and implementation consequences

This reference is self-contained and was prepared from the source material
provided for this build. It is organised by operational problem, not by book,
and does not depend on the source files remaining available.

## Admission decisions

The PowerShell books support stable toolmaking concepts: pipeline-friendly
objects, advanced functions, parameter validation, error semantics, help,
modules, testing, remoting boundaries, and separation of reusable commands from
presentation. Their individual command examples remain version-sensitive.

The AD books support the domain model and diagnostic map: partitions and schema,
sites and replication, DNS/time/Kerberos dependencies, FSMO roles, trusts, OUs,
users/groups/computers, GPO, recovery, certificates, and hybrid identity. The
2003-era Active Directory and 2005 Windows Internals editions are historical
sources only. They cannot establish a current command, default, support status,
security control, or event identifier.

The Sysinternals source supports a hypothesis-led escalation ladder: start with
native state and logs, then select the smallest tool whose trace discriminates
between competing hypotheses. Process Monitor, Process Explorer, Autoruns,
ProcDump, PsTools, and other utilities are not a generic “run everything” kit.
Collection windows, filters, privacy, output size, and evidence preservation
must be decided before a trace begins.

## Critical review of the AD cookbook code repository

The supplied companion repository contains 256 files across 16 chapter folders,
including 170 PowerShell scripts and 80 command files. It is valuable as a
capability inventory covering forests/trusts, domain controllers, FSMO, OUs,
sites/replication, users, groups, computers, DNS, GPO, security/recovery, AD CS,
AD FS, synchronisation, and hybrid identity.

Static inspection of the 170 PowerShell files found no occurrence of
`CmdletBinding`, `SupportsShouldProcess`, `WhatIf`, `ConfirmImpact`, explicit
`ErrorAction`, or `try/catch`. One script uses plaintext-to-`SecureString`
conversion. Representative destructive files consist of direct commands such
as DC demotion, FSMO seizure, object deletion, and domain-policy restoration,
often with example-specific host or domain values.

These findings do not make the examples malicious or useless; they establish
that the repository is instructional recipe code, not a production automation
library. This engine therefore:

- imports no cookbook script;
- uses filenames and topics to expand capability and negative-test coverage;
- rewrites any adopted operation behind advanced-function, target, authority,
  preview, typed result, error, verification, and recovery contracts;
- treats forest level, legacy tooling, Azure AD naming, LAPS, AD FS, sync, and
  Graph examples as version-sensitive; and
- blocks destructive AD operations until a disposable multi-DC lab proves the
  failure and recovery paths.

## PowerShell engineering rules distilled from the corpus

| Problem | Engine rule |
|---|---|
| Reusable commands | Use approved verb-noun names, `[CmdletBinding()]`, typed and validated parameters, and object output. |
| Pipeline composition | Accept pipeline input only where semantics are unambiguous; never emit formatted text from the data layer. |
| Errors | Convert expected failures to structured errors; preserve native exit code/stdout/stderr; never use an empty catch. |
| Mutation | Declare `SupportsShouldProcess`; capture state before mutation; verify outcome separately. |
| Secrets | Accept credential objects or secret-provider references, never plaintext CLI values or evidence fields. |
| Remoting | Record transport, authentication, endpoint, target identity, timeout, and disconnect risk. |
| Idempotence | A second authorised run reports `NoChange`; exceptions state why repetition is unsafe. |
| Modules | Public functions are thin; private functions own shared validation, redaction, evidence, and result construction. |
| Compatibility | Windows PowerShell 5.1 and PowerShell 7 are separate test rows; compatibility is never inferred. |

## AD diagnostic order

1. Prove target forest/domain/DC identity and collection time.
2. Check IP configuration, DNS client/server path, DC locator, and time.
3. Inspect role/service availability and recent Directory Service, DNS Server,
   DFS Replication, System, and security-relevant events.
4. Collect replication summaries and per-partner metadata; preserve failures by
   naming context and partner.
5. Locate FSMO owners and verify they are reachable; do not move or seize roles
   during diagnosis.
6. Test secure channels, trusts, Kerberos/SPN/delegation hypotheses only after
   DNS and time evidence is available.
7. Rank hypotheses and name the next discriminating check. Mutation is a new,
   separately authorised operation.

## GPO and identity safety consequences

Effective policy is the result of scope, link order, inheritance, enforcement,
security filtering, WMI filtering, loopback, client-side extension behaviour,
replication, and management ownership. A registry observation alone does not
prove which controller owns a setting. Back up the exact GPO and record its ID,
version, links, permissions, and results before a change.

Identity evidence must use stable keys (SID, object GUID, distinguished name
where appropriate) alongside readable names. Rename, move, disable, delete,
group membership, SPN, delegation, password, LAPS, and recovery operations need
explicit identity, scope, expiry where relevant, approval, and post-replication
verification. Secrets never enter normal result objects.

## Windows internals and troubleshooting consequences

Concepts such as process/thread boundaries, virtual memory, handles, I/O,
security tokens, services, drivers, registry, filesystem, networking, and crash
dumps guide evidence selection. Implementation details from old editions are
not assumed current. A troubleshooting result contains symptom, observations,
competing hypotheses, confidence, next discriminating test, collected evidence,
privacy limits, and separately authorised repair options.

## Gaps retained for lab and current-source verification

- Windows Server 2025/2022/2019 and Server Core behaviour.
- PowerShell 7 compatibility for Windows-only modules.
- Non-English locale and 32/64-bit registry views.
- Multi-DC replication, trust, GPO, LAPS, gMSA, AD CS, AD FS, and forest recovery.
- Hyper-V/cluster, IIS, VSS/system-state restore, WinRM workgroup, Intune, Arc,
  Windows Admin Center, and mixed fleet partial failure.

Each gap is `NOT_ASSESSED`, with the intended lab described under `labs/`.
