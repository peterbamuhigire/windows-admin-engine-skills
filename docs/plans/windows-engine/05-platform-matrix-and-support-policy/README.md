# Phase 05 — Platform matrix and support policy

## Purpose

Prevent version and role ambiguity. Every skill must tell the agent what it supports, what it has tested, and what it does not know.

## Workstreams

### 5.1 Operating-system matrix

Define policy for Windows Server 2025, 2022, 2019, and any later supported release; Windows 11 supported channels; Server Core; Desktop Experience; domain controller; member server; workgroup; Windows client; and management workstation.

### 5.2 Runtime matrix

Test and document Windows PowerShell 5.1, PowerShell 7, Python versions, architecture, locale, code page, execution policy, module availability, 32/64-bit registry view, and interactive versus non-interactive sessions.

### 5.3 Management-plane matrix

Record whether a capability is controlled by local policy, GPO, MDM/Intune, DSC, Configuration Manager, application installer, Windows Admin Center, Azure Arc, or a third-party platform. Detect policy ownership before proposing mutation.

### 5.4 Support statuses

Use SUPPORTED, LAB_VALIDATED, PARTIAL, EXPERIMENTAL, BLOCKED, NOT_ASSESSED, and DEPRECATED with a reason, evidence path, last test date, and review date.

## Required artifacts

- engine/platform-matrix.yaml
- platform fingerprint schema
- locale and architecture test fixtures
- support-status vocabulary
- version-sensitive source register
- compatibility decision template

## Verification

- Run representative read-only probes on every claimed platform.
- Test missing modules, unavailable roles, Server Core, non-English locale, non-admin identity, and remote host.
- Confirm a skill does not silently fall back to a different platform or management plane.
- Confirm unsupported combinations produce a bounded report, not a guessed command.

## Exit gate

Every first-release skill has a completed platform row and evidence. The engine can distinguish “not supported” from “not tested” and does not make a current-version claim without a current source record.

## Dependencies and risks

Depends on Phases 03 and 04. Windows and PowerShell change independently; use source freshness and lab revalidation rather than assuming an old command remains correct.
