---
name: windows-hyper-v
description: Use when inventorying or diagnosing Hyper-V hosts, switches, VMs, checkpoints, replication, cluster boundaries, Windows containers, or WSL; use workload specialists for guest application health.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Hyper-V and Virtualisation

<!-- dual-compat-start -->

## Use when

- Inspect host, VM, virtual switch, disk, checkpoint, integration, or replication state.
- Diagnose host/guest resource or network boundaries.
- Plan bounded VM/host maintenance.

## Do not use when

- Host state is being used as proof of guest application health.
- A checkpoint is proposed as a backup strategy.

## Inputs

Host/cluster, VM IDs, workload owners, resource/availability requirements,
backup status, network/storage topology, window, and out-of-band access.

## Platform and privilege boundary

Discovery is R0 with delegated Hyper-V rights. VM/host/switch/checkpoint/cluster
changes are R2-R5 and `NOT_ASSESSED` in 0.1.

## Workflow

1. Resolve host/cluster and inventory affected guests and owners.
2. Capture VM, resource, disk, switch, integration, replication, checkpoint,
   storage, network, and backup boundaries.
3. Distinguish host, virtual network/storage, guest OS, and application evidence.
4. For maintenance, define drain/move/shutdown order, capacity, rollback, and probes.
5. Verify each guest application separately after host state recovers.

## Mutation, verification, and recovery

Host change verification includes guest reachability and workload probes.
Checkpoint cleanup and merge require storage headroom and recovery plan.

## Stop conditions

Stop on unknown guest owner, insufficient failover capacity, quorum warning,
unhealthy backup, active merge/replication fault, or missing out-of-band access.

## Capability contract and degraded mode

Read Hyper-V cmdlets when available. Without lab/rights, output topology fields
and a `NOT_ASSESSED` plan; do not infer guest health.

## Outputs

Host/guest topology, blast radius, resource/replication/checkpoint findings,
maintenance/recovery plan, per-guest outcome, and limitations.

## Decision rules

| Condition | Action |
|---|---|
| Guest app unhealthy, VM running | Route into guest workload |
| Checkpoint old/growing | Plan owner-approved merge; not a backup claim |
| Cluster capacity insufficient | Block drain/maintenance |
| Image provenance unknown | Block container deployment |

## Quality standards

Use VM IDs with names, preserve host/guest ownership, and prove application
outcomes beyond virtual machine state.

## Anti-patterns

- “VM running” equals healthy. Fix: guest probe.
- Snapshot before every change as backup. Fix: supported backup.
- Moving roles without quorum/capacity. Fix: cluster plan.
- Deleting checkpoint under pressure. Fix: merge/storage analysis.
- Mixing WSL dev and production contract. Fix: state boundary.

## References

- [`docs/safety-model.md`](../../../docs/safety-model.md)
- [`engine/platform-matrix.yaml`](../../../engine/platform-matrix.yaml)
<!-- dual-compat-end -->
