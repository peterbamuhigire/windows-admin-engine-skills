# Phase 02 — Linux parity audit and Windows capability map

## Purpose

Use linux-skills as a capability benchmark, not a command template. Identify what Windows must cover, what is genuinely different, what should be shared as cross-platform operating doctrine, and what must remain a Windows-native specialist.

## Workstreams

### 2.1 Inventory the Linux engine

Record for every Linux skill:

- responsibility, trigger, exclusions, handoffs, references, scripts, tests, output shape, and maturity;
- whether it is read-only, reversible, service-impacting, access-risk, or destructive;
- script installation tier and CLI discoverability;
- evidence, rollback, idempotency, and platform coverage;
- gaps found by the Linux engine's own analysis and Kaizen records.

### 2.2 Build the Windows crosswalk

Create a matrix with columns:

| Linux skill/family | Windows owner | Shared doctrine | Native Windows boundary | Script candidates | Lab required | Initial status |
|---|---|---|---|---|---|---|

Use the root plan's parity table as a starting point, then validate each row against actual Windows management surfaces.

### 2.3 Identify Windows-only domains

Add explicit coverage for AD DS, GPO, Kerberos, LDAP, DNS/DHCP, WinRM, CIM, RSAT, Windows Admin Center, Defender, BitLocker, LAPS, JEA, IIS, NTFS/SMB/DFS, Hyper-V, Failover Clustering, VSS, Event Log/ETW, WinDbg, WPR/WPA, Windows containers, WSL, WinGet, Intune, Entra, Azure Arc, and Microsoft security baselines.

### 2.4 Separate capability from product integration

Do not imply that a generic Windows skill supports Exchange, SQL Server, SCCM, Intune, Azure, third-party backup, or cluster products. Create an adapter boundary and an explicit support status for each integration.

## Required artifacts

- Linux-to-Windows capability crosswalk
- Windows capability catalogue
- domain ownership map
- coverage gap register
- duplicate-risk register
- first-release script candidate map
- routing-neighbour map showing where Linux, Windows, engineering, finance, SRS, or research engines must be added

## Verification

- Cross-check the crosswalk against every Linux numbered family and every shared CLI feature.
- Review the map with a Windows administrator and a Linux administrator.
- Mark schema-only or menu-only capabilities as NOT_ASSESSED until an application boundary or executable Windows test exists.
- Identify the smallest useful Windows capability that can prove the foundation.

## Exit gate

Every Linux family has a Windows owner or an explicit defer/unsupported reason. Every first-release Windows domain has a skill candidate, evidence type, lab requirement, and risk class. No skill is created solely because a product name appeared in a list.

## Dependencies and risks

Depends on Phase 01 and the current Linux repository audit. The main risk is copying Linux taxonomy too literally. Resolve it by retaining the operating model while using Windows-native terminology and control boundaries.
