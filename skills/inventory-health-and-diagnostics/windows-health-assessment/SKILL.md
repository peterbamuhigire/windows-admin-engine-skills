---
name: windows-health-assessment
description: Use when assessing role-aware Windows health, capacity, pending reboot, services, updates, recent errors, certificates, or workload readiness; use windows-troubleshooting for root-cause investigation.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Health Assessment

<!-- dual-compat-start -->

## Use when

- Produce a bounded host health readout before or after change.
- Identify capacity, service, reboot, event, update, or role warnings.
- Separate healthy, unhealthy, not applicable, unsupported, and unassessed checks.

## Do not use when

- The cause is unknown and spans components; use `windows-troubleshooting`.
- The request authorises repair; assessment does not grant mutation.

## Inputs

Fresh inventory, target role, expected workloads, lookback window, thresholds,
maintenance context, and evidence path.

## Platform and privilege boundary

R0. Some event, Defender, backup, replication, and role checks need elevation or
modules; unavailable checks remain visible.

## Workflow

1. Confirm target and role applicability.
2. Run `Test-WseSystemHealth` with explicit disk and event windows.
3. Add only role-specific checks supported by the platform row.
4. Record finding severity, confidence, source, owner, and next discriminating action.
5. Verify after change with the same oracle and comparable collection window.

## Mutation, verification, and recovery

No repair occurs. Verification checks observed workload outcomes. Recovery is a
handoff to the owning specialist with the pre-change baseline attached.

## Stop conditions

Stop diagnosis when target, role, baseline, time window, or collection rights are
insufficient to distinguish a failure from an unavailable check.

## Capability contract and degraded mode

Read and local execution are required for observed findings. Without them,
produce a check plan and label the assessment `NOT_ASSESSED`.

## Outputs

Operation envelope, role-aware findings, recent events, pending-reboot state,
unassessed list, ranked next actions, and evidence hash.

## Decision rules

| Observation | Result |
|---|---|
| Missing irrelevant role | Not applicable |
| Collector unavailable | Not assessed |
| Threshold breached with evidence | Finding with severity and owner |
| Symptom remains unexplained | Route to troubleshooting |

## Quality standards

Thresholds are explicit; findings do not overclaim root cause; collection does
not modify the host.

## Anti-patterns

- “Healthy” from uptime alone. Fix: use role checks.
- Treating event count as root cause. Fix: correlate time and symptom.
- Hiding unavailable checks. Fix: list them.
- Auto-restarting failed services. Fix: inspect dependencies and role.
- Comparing incompatible snapshots. Fix: require schema and target match.

## References

- [`docs/research/source-synthesis.md`](../../../docs/research/source-synthesis.md)
- [`engine/platform-matrix.yaml`](../../../engine/platform-matrix.yaml)
<!-- dual-compat-end -->
