---
name: windows-patch-management
description: Use when discovering or planning Windows updates, servicing, installed software, maintenance windows, patch rings, failure handling, or reboot readiness; use windows-health-assessment for health-only checks.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Patch Management

<!-- dual-compat-start -->

## Use when

- Inventory update/build/pending-reboot state and ownership.
- Plan download, install, reboot, validation, rollback, or fleet rings.
- Diagnose a failed servicing or application update.

## Do not use when

- The request implies an unapproved production reboot.
- An application owner or endpoint management plane is unknown.

## Inputs

Target/role, update source and owner, maintenance window, approval ring,
dependencies, reboot policy, workload health oracle, rollback boundary, and SLA.

## Platform and privilege boundary

Discovery is R0. Install is R2; remote-access or security-agent changes may be
R3/R4. Executable mutation is `NOT_ASSESSED` in 0.1.

## Workflow

1. Capture OS/build, source, update history/failures, servicing and reboot state.
2. Classify OS, quality, security, feature, driver, firmware, and application updates.
3. Detect Intune/WUfB/ConfigMgr/Arc/local/vendor ownership.
4. Define canary, prechecks, install, explicit reboot, readiness, observation,
   failure threshold, and rollback/escalation.
5. Preserve per-host outcomes and verify the workload after reboot.

## Mutation, verification, and recovery

Never reboot implicitly. Recovery distinguishes uninstall/rollback, restore,
known-issue mitigation, and roll-forward. Verify boot plus user-visible workload.

## Stop conditions

Stop on pending prior reboot, unhealthy role, cluster owner uncertainty, missing
maintenance window, unavailable recovery, metered/offline condition, or competing plane.

## Capability contract and degraded mode

Read discovery by default. Mutation requires approved adapter and lab evidence;
otherwise produce a bounded patch plan with `BLOCKED` execution.

## Outputs

Patch state, source/owner, ring manifest, reboot state machine, per-host results,
post-reboot health, rollback decision, and limitations.

## Decision rules

| Condition | Action |
|---|---|
| No applicable updates from defined source | NoChange with source/time |
| Pending reboot exists | Resolve before new install unless policy says otherwise |
| Cluster/workload cannot drain | Block host reboot |
| Canary exceeds failure threshold | Stop wider ring |

## Quality standards

“Up to date” always names source, classification, scope, timestamp, and method.
Second run is no-op where the servicing plane permits.

## Anti-patterns

- Rebooting inside install command. Fix: separate approved stage.
- Updating all hosts first. Fix: canary ring.
- Mixing package owners. Fix: detect management plane.
- Treating boot as readiness. Fix: workload probe.
- Hiding failed hosts in aggregate. Fix: per-target state.

## References

- [`docs/safety-model.md`](../../../docs/safety-model.md)
- [`engine/platform-matrix.yaml`](../../../engine/platform-matrix.yaml)
<!-- dual-compat-end -->
