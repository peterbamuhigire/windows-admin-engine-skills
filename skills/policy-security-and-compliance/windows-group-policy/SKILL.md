---
name: windows-group-policy
description: Use when analysing GPO ownership, scope, precedence, inheritance, filtering, result, backup, staged change, or rollback; use windows-security-analysis for posture assessment.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Group Policy

<!-- dual-compat-start -->

## Use when

- Explain resultant policy or conflicting local/GPO/MDM ownership.
- Inventory GPO links, versions, filters, permissions, or replication state.
- Prepare a test-ring policy change and rollback.

## Do not use when

- A registry value alone is being treated as policy ownership.
- The request is a broad security assessment without a GPO problem.

## Inputs

Forest/domain, GPO GUID, target users/computers/OUs, sites, link order,
inheritance/enforcement, filters, loopback, client extension, approval, and ring.

## Platform and privilege boundary

Read-only modelling is R0. GPO creation, link, permission, restore, default-policy,
or enforcement changes are R4 and blocked until the domain lab passes.

## Workflow

1. Prove target domain and replication health.
2. Capture GPO ID, versions, links, permissions, filters, backups, and owner.
3. Collect GPResult/RSoP for an affected principal and computer.
4. Explain precedence and the controlling management plane.
5. For authorised change, back up exact GPO, use a test OU/ring, verify result,
   observe, expand, or roll back.

## Mutation, verification, and recovery

Verification uses resultant policy on representative clients after replication
and refresh, plus intended workload outcome. Recovery restores the exact backup
or reverses the link/change, then verifies results again.

## Stop conditions

Stop on unhealthy replication, missing GPO backup, default policy reset request,
unknown filter/loopback effect, broad scope, unproved recovery, or competing MDM.

## Capability contract and degraded mode

Read GPO/RSoP evidence. Mutation requires domain lab, peer approval, and test
ring. Otherwise output a `BLOCKED` change plan.

## Outputs

Policy ownership map, resultant-policy explanation, affected-scope estimate,
backup identity, staged plan, verification oracle, and rollback record.

## Decision rules

| Condition | Action |
|---|---|
| Local value differs from GPO | Report effective owner; do not fight it locally |
| Replication unhealthy | Block policy change |
| Scope cannot be bounded | Use test OU/security filter or stop |
| Default GPO damage suspected | Diagnose and obtain recovery authority |

## Quality standards

Every conclusion names scope, precedence, replication timestamp, and evidence
source. A screenshot is supporting context, not a policy contract.

## Anti-patterns

- Editing Default Domain Policy casually. Fix: dedicated policy and review.
- Inferring owner from registry. Fix: RSoP and management-plane evidence.
- Linking at domain root first. Fix: test ring.
- Ignoring loopback/filtering. Fix: model complete scope.
- Restoring without version evidence. Fix: identify exact backup.

## References

- [`docs/research/source-synthesis.md`](../../../docs/research/source-synthesis.md)
- [`docs/safety-model.md`](../../../docs/safety-model.md)
<!-- dual-compat-end -->
