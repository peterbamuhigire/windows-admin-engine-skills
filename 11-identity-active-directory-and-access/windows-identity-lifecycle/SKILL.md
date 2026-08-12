---
name: windows-identity-lifecycle
description: Use when planning gated local or AD user, group, computer, gMSA, SPN, LAPS, join, disable, move, expiry, or offboarding work; use windows-active-directory-health for diagnosis.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Identity Lifecycle

<!-- dual-compat-start -->

## Use when

- Provision, modify, disable, expire, move, or deprovision an identity.
- Change group membership, service identity, SPN, delegation, LAPS, or domain join.
- Review least privilege, nested access, expiry, or historical attribution.

## Do not use when

- The request is only directory health.
- The operator asks to print a password, LAPS value, token, or recovery secret.

## Inputs

Stable object key, target domain/host, business owner, lifecycle event, requested
access, start/expiry, approval, separation of duties, and recovery action.

## Platform and privilege boundary

R4 by default; destructive identity recovery can be R5. Mutations are
`NOT_ASSESSED` and blocked in 0.1 pending delegated multi-DC lab evidence.

## Workflow

1. Resolve object by stable key and prove domain/tenant.
2. Capture current memberships, ownership, SPNs/delegation, protection, and policy.
3. Calculate effective privilege and replication consequences.
4. Prepare a minimal, time-bounded change with independent approval.
5. Execute only through a lab-validated owner; verify replication and effective access.
6. Preserve attribution and reversible disable before deletion when policy allows.

## Mutation, verification, and recovery

Use preview, explicit identity, expiry, rollback, and post-replication checks.
Password/secret rotation has a separate protected channel and consumer update
plan. Deletion requires recovery-object or backup proof.

## Stop conditions

Stop on duplicate name, ambiguous key, stale replication, protected/privileged
object, unknown application dependency, missing approver, unavailable recovery,
or request to expose secret material.

## Capability contract and degraded mode

Read directory and approval artefacts. Mutation requires delegated rights and a
validated lab adapter. Otherwise return a change packet with `BLOCKED` verdict.

## Outputs

Identity decision record, before/after safe attributes, access delta, approvals,
expiry, replication/effective-access verification, and recovery reference.

## Decision rules

| Condition | Action |
|---|---|
| Leaver with uncertain dependency | Disable and investigate; do not delete |
| Temporary privilege | Expiring membership with owner and review |
| Service account | Prefer gMSA where supported and application-compatible |
| Secret requested in evidence | Refuse and route to protected retrieval |

## Quality standards

Least privilege, stable identity keys, expiration, separation, and replication
verification are explicit. Historical attribution is preserved.

## Anti-patterns

- Resolving by display name only. Fix: use SID/GUID/DN as appropriate.
- Permanent emergency access. Fix: expiry and review.
- Delete-first offboarding. Fix: reversible disable and dependency check.
- Duplicating an SPN. Fix: search forest-wide before change.
- Logging credentials. Fix: keep secret channel outside evidence.

## References

- [`docs/research/source-synthesis.md`](../../docs/research/source-synthesis.md)
- [`docs/safety-model.md`](../../docs/safety-model.md)
<!-- dual-compat-end -->
