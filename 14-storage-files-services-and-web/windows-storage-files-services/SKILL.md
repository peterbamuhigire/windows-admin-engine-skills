---
name: windows-storage-files-services
description: Use when diagnosing or planning Windows disks, volumes, NTFS/ReFS, SMB/DFS, ACLs, handles, VSS, services, or scheduled tasks; use windows-iis for IIS-specific workload state.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Storage, Files, and Services

<!-- dual-compat-start -->

## Use when

- Inspect capacity, disk/volume health, filesystem, VSS, SMB/DFS, or permissions.
- Diagnose a Windows service, dependency, account, path, or scheduled task.
- Perform the engine's bounded local service-state proof.

## Do not use when

- Formatting/resizing/destructive cleanup lacks R5 authority and backup proof.
- Permission correctness is being inferred from ACL text without effective access.

## Inputs

Target/role, disk/volume/share/path/service/task stable identifier, intended
outcome, owner, active dependencies, access principal, window, and recovery.

## Platform and privilege boundary

Discovery is R0. Service start/stop is R2. ACL/share/storage mutations range
R2-R5 and remain blocked unless a specific lab row passes.

## Workflow

1. Run `Get-WseStorageServiceSnapshot` with the narrowest scope.
2. Map disks to partitions/volumes/mounts/workloads before a storage decision.
3. For access, combine share and NTFS rules, inheritance, groups, deny rules,
   ownership, and effective-access evidence.
4. For service/task, inspect dependencies, account, binary/action, signatures,
   triggers, history, events, and workload probe.
5. Use `Invoke-WseServiceState` only with authority, window, preview, and evidence.

## Mutation, verification, and recovery

Verify filesystem/share/service user outcome, not configuration alone. Restore
service state on failed verification. Storage/ACL recovery needs known-good
metadata and must preserve confidentiality as well as availability.

## Stop conditions

Stop on unknown disk mapping, active workload/cluster, full-volume write risk,
missing backup, permission-owner ambiguity, unsigned service binary concern, or
no effective-access test.

## Capability contract and degraded mode

Read collectors are available locally. Only service state has a controlled
mutation command in 0.1; return `BLOCKED` for other changes.

## Outputs

Storage/share/service/task snapshot, dependency and access analysis, risk,
change preview, verification, rollback artefact, and evidence pack.

## Decision rules

| Condition | Action |
|---|---|
| Low capacity | Diagnose owner/growth; never delete automatically |
| Service stopped but role unknown | Investigate before start |
| Share allows but NTFS denies | Effective access is denied |
| Destructive storage request | R5 backup and typed decision |

## Quality standards

Use stable IDs, byte counts, and object output. A second service-state run is
`NoChange`. Sensitive file contents are never collected by default.

## Anti-patterns

- Deleting “old” files blindly. Fix: owner/retention evidence.
- Using checkpoints as backup. Fix: approved recovery system.
- Restarting dependencies together. Fix: one bounded change.
- Reading ACL text only. Fix: calculate effective access.
- Changing service account casually. Fix: identity and dependency plan.

## References

- [`docs/research/source-synthesis.md`](../../docs/research/source-synthesis.md)
- [`docs/safety-model.md`](../../docs/safety-model.md)
<!-- dual-compat-end -->
