# Phase 12 — Policy, security, and compliance

## Purpose

Turn Windows security guidance into auditable, source-versioned assessments and carefully staged remediation rather than blind hardening scripts.

## Workstreams

### 12.1 Baseline assessment

Integrate Microsoft Security Compliance Toolkit outputs and, where legally licensed, CIS/STIG/NIST mappings. Record baseline version, product/build, policy owner, applicability, exceptions, and evidence.

### 12.2 Security controls

Cover Defender, firewall, attack-surface reduction, BitLocker, Secure Boot, VBS, Credential Guard, AppLocker/WDAC, audit policy, PowerShell logging, script controls, local rights, SMB, RDP, TLS/certificates, LAPS, update status, and removable media boundaries.

### 12.3 Policy ownership

Detect whether a setting is local, GPO, MDM/Intune, DSC, ConfigMgr, security product, application, or vendor-owned. Report conflicts and effective policy before proposing a change.

### 12.4 Remediation boundaries

Separate assessment, recommendation, staged change, enforcement, exception, and rollback. High-risk security changes require peer review, test ring, recovery access, and a measured verification window.

## Required artifacts

- windows-security-analysis skill
- windows-hardening skill
- security baseline adapter
- control crosswalk schema
- exception and expiry register
- audit evidence pack
- sensitive-security-data redaction tests

## Verification

Test clean baseline, drift, conflicting policy, missing baseline, unsupported edition, non-admin assessment, Defender unavailable, BitLocker recovery-key boundary, WDAC/AppLocker denial, and rollback of a reversible control.

## Exit gate

The engine can report security posture with source and scope, but cannot claim compliance from a screenshot or a single registry value. Remediation is blocked when policy ownership, recovery, or source currency is unknown.

## Dependencies and risks

Depends on Phases 03, 06, 08, and 11. Baselines are versioned recommendations, not universal law; preserve applicability and exceptions.
