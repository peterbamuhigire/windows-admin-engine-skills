---
name: windows-backup-recovery
description: Use when assessing protection or planning a file, volume, system-state, bare-metal, VM, AD, or configuration restore test; use workload specialists for application-native recovery.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Backup and Recovery

<!-- dual-compat-start -->

## Use when

- Inventory backup coverage, age, retention, encryption, off-site copy, RPO, or RTO.
- Plan a clean-room restore or disaster-recovery exercise.
- Diagnose missing chain, corruption, key, space, VSS, or provider failure.

## Do not use when

- A checkpoint is being treated as backup.
- Restore target or overwrite scope is ambiguous.

## Inputs

Protected assets/workloads, owner, provider/catalog, recovery point, RPO/RTO,
retention, encryption/key availability, clean target, dependencies, and authority.

## Platform and privilege boundary

Inventory is R0. Restore is R5 by default. All executable restore modes are
`NOT_ASSESSED` until provider-specific clean-room lab evidence exists.

## Workflow

1. Map assets, consistency boundary, provider, schedule, retention, and owners.
2. Verify catalogue/job identity, hashes where provided, chain, keys, space, and target.
3. Select a recovery point against stated RPO and business event.
4. Restore to isolated target without overwriting unrelated data.
5. Validate identity, ACLs, timestamps, configuration, data, and workload outcome.
6. Measure achieved RPO/RTO and record exceptions and escalation.

## Mutation, verification, and recovery

The restore itself is the high-risk change. A failed restore must leave the
original and unrelated targets intact. Verification is workload-specific and
includes security and attribution, not file presence alone.

## Stop conditions

Stop on wrong target, missing approval, unknown recovery point, corrupt/missing
chain, unavailable key, insufficient space, live overwrite, or absent validation oracle.

## Capability contract and degraded mode

Read catalogues and plans. Execute restore only in an approved clean lab through
a validated adapter. Otherwise return `BLOCKED` with exact missing proof.

## Outputs

Protection inventory, policy gap, selected recovery point, clean-target contract,
restore logs/IDs/hashes, validation, achieved RPO/RTO, and recovery verdict.

## Decision rules

| Condition | Action |
|---|---|
| Job succeeded, no restore test | Protection unproved |
| Recovery point misses RPO | Escalate; do not relabel |
| Restore requires overwrite | R5 typed decision and alternate preservation |
| App consistency unknown | Route to application owner |

## Quality standards

Backup claims require recovery evidence at representative scope. Keys and
secrets remain outside ordinary evidence.

## Anti-patterns

- Success email equals recoverable. Fix: restore test.
- Restoring into production first. Fix: clean room.
- Checking only file count. Fix: workload validation.
- Ignoring ACL/identity. Fix: verify security metadata.
- Hiding missed RTO. Fix: record measured result.

## References

- [`docs/safety-model.md`](../../../docs/safety-model.md)
- [`docs/threat-model.md`](../../../docs/threat-model.md)
<!-- dual-compat-end -->
