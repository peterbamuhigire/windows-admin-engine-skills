---
name: windows-security-analysis
description: Use when producing a read-only Windows security posture, effective-control, drift, exception, or versioned baseline assessment; use windows-group-policy for policy mechanics and ownership.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Security Analysis

<!-- dual-compat-start -->

## Use when

- Assess Defender, firewall, BitLocker, Secure Boot, audit, logging, WDAC/AppLocker, TLS, SMB, RDP, LAPS, or update posture.
- Compare against a versioned Microsoft baseline.
- Record control ownership, exceptions, evidence, and uncertainty.

## Do not use when

- The request is to apply hardening automatically.
- A formal certification is expected from one scan or screenshot.

## Inputs

Target fingerprint, role, data classification, threat context, baseline/version,
management-plane owners, exceptions, and evidence retention limits.

## Platform and privilege boundary

Assessment is R0; some fields need elevation. Remediation ranges R1-R4 and is
outside the current executable scope.

## Workflow

1. Resolve target, role, edition/build, and policy owners.
2. Run `Get-WseSecuritySnapshot` and versioned baseline adapters where available.
3. Separate configured, effective, active, and observed controls.
4. Record applicability, source version, exception owner/expiry, and evidence.
5. Rank remediation by risk and stage it through the owning plane.

## Mutation, verification, and recovery

Assessment cannot authorise remediation. Any hardening change needs compatibility
testing, recovery access, ring, outcome monitoring, and rollback.

## Stop conditions

Stop compliance claims on missing baseline version, unsupported edition,
unknown policy owner, absent recovery path, stale evidence, or hidden exception.

## Capability contract and degraded mode

Read and execute approved collectors. Without privilege or baseline, retain each
unassessed control; never score it as passed.

## Outputs

Control/effective-owner matrix, findings with severity/confidence, exceptions,
source version, remediation plan, and non-certification statement.

## Decision rules

| Evidence | Classification |
|---|---|
| Setting present but effect untested | Configured, not verified |
| Tool unavailable | Not assessed |
| Baseline not applicable | Not applicable with reason |
| Conflicting owners | Block remediation and resolve ownership |

## Quality standards

No single registry value or screenshot proves compliance. Sensitive security
data and recovery material are omitted from normal evidence.

## Anti-patterns

- Disabling controls to “fix” compatibility. Fix: staged exception and owner.
- Applying a baseline without version. Fix: pin build/baseline.
- Counting missing data as pass. Fix: not assessed.
- Exposing BitLocker recovery keys. Fix: record protection status only.
- Competing with GPO/MDM. Fix: remediate through owner.

## References

- [`engine/source-register.yaml`](../../engine/source-register.yaml)
- [`docs/threat-model.md`](../../docs/threat-model.md)
<!-- dual-compat-end -->
