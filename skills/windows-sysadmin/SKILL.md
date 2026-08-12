---
name: windows-sysadmin
description: Use when a Windows request needs routing across host, domain, network, security, workload, recovery, fleet, or development administration; use windows-troubleshooting first when an unexplained symptom spans components.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Administration Hub

<!-- dual-compat-start -->

## Use when

- The correct Windows specialist is not yet known.
- A request crosses host, domain, workload, network, security, or fleet boundaries.
- The operator needs the repository-wide target, authority, evidence, and safety contract.

## Do not use when

- The request already matches one specialist in `engine/catalog.yaml`.
- The target is Linux; route to the Linux engine.
- The work is application implementation rather than Windows operations; add the engineering engine.

## Inputs

Require intended outcome or observed symptom, explicit target or inventory key,
host role, environment, identity context, and authority boundary. For mutation,
also require management owner, risk class, change window, verification, and
recovery.

## Platform and privilege boundary

Routing is read-only. Do not infer Windows edition, domain/tenant, elevation, or
production authority. Use `engine/platform-matrix.yaml`; `NOT_ASSESSED` is not
support.

## Workflow

1. Classify local, remote, fleet, domain, tenant, or hybrid scope.
2. Classify discovery, diagnosis, mutation, recovery, or compliance intent.
3. Run `scripts/windows-admin.ps1 route "<request>"` or inspect the catalogue.
4. Load the highest-ranked specialist and its dependencies.
5. Resolve target and management ownership before commands.
6. Keep first pass read-only unless mutation is explicit.
7. Verify the named outcome and write a redacted operation record.

## Mutation, verification, and recovery

R1-R5 rules in `docs/safety-model.md` apply. The hub cannot authorise a change.
If the first route fails, return to observed evidence and select the nearest
diagnostic skill; do not guess a repair.

## Stop conditions

Stop on ambiguous or stale target, missing authority, unknown policy owner,
unsupported platform, unavailable backup/recovery prerequisite, cross-tenant
uncertainty, or any request to return a secret as ordinary output.

## Capability contract and degraded mode

Read/search the catalogue and request. Without target access, return up to three
routes and name the fact that separates them. Do not issue mutating commands.

## Outputs

Return ranked route, rejected neighbour where relevant, target/authority
handoff, risk class, verification target, and unassessed conditions.

## Decision rules

| Condition | Route |
|---|---|
| Unknown cause spans components | `windows-troubleshooting` |
| AD replication/DNS/time/trust symptom | `windows-active-directory-health` |
| Security posture only | `windows-security-analysis` |
| All-machines or management-plane work | `windows-fleet-management` |
| Restore or destructive recovery | `windows-backup-recovery` |

## Quality standards

Route explicitly, preserve read-only defaults and per-target results, and never
claim completion without outcome evidence.

## Anti-patterns

- Guessing from one keyword. Fix: compare outcome and nearest exclusions.
- Staying in the hub. Fix: hand off quickly.
- Assuming a `wsa-*` command is installed. Fix: discover it first.
- Treating user wording as approval. Fix: require authority record.
- Flattening partial fleet success. Fix: preserve every target result.
- Calling exit code zero healthy. Fix: run the specialist verification oracle.

## References

- [`engine/catalog.yaml`](../../engine/catalog.yaml)
- [`docs/safety-model.md`](../../docs/safety-model.md)
- [`docs/threat-model.md`](../../docs/threat-model.md)
<!-- dual-compat-end -->
