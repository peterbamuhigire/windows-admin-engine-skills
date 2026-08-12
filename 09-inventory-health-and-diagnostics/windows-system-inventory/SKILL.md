---
name: windows-system-inventory
description: Use when collecting a read-only Windows host fingerprint, role, runtime, volume, software, service, certificate, or drift baseline; use windows-health-assessment for health findings.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows System Inventory

<!-- dual-compat-start -->

## Use when

- Establish target identity and platform before another operation.
- Capture a workstation, server, or Server Core baseline.
- Compare allow-listed configuration snapshots for drift.

## Do not use when

- A symptom needs diagnosis; use `windows-health-assessment` or `windows-troubleshooting`.
- The request asks to install, remove, or update software.

## Inputs

Explicit hostname or local target, environment, collection scope, data
minimisation rules, freshness limit, and evidence destination.

## Platform and privilege boundary

R0. Standard-user collection is preferred. Missing privileged fields are
`NOT_ASSESSED`. The 0.1 executable collector is local-only.

## Workflow

1. Resolve the target and record machine fingerprint and time.
2. Run `Get-WseSystemInventory`; add narrow collectors only when needed.
3. Collect object properties, not formatted or localised command text.
4. Exclude secrets, raw user data, recovery material, and unrestricted exports.
5. Compare snapshots only when schema and target fingerprint match.

## Mutation, verification, and recovery

No host mutation is allowed. Evidence-file creation is the only write. Verify
collector availability, target identity, timestamp, schema, and redaction.

## Stop conditions

Stop on ambiguous target, stale inventory, unexpected remote target, sensitive
field request, schema mismatch, or a collector that would change state.

## Capability contract and degraded mode

Read/execute local collectors; write only to an approved evidence path. Without
execution, return the field plan and mark all values unobserved.

## Outputs

Versioned operation envelope, platform fingerprint, scoped inventory, warnings,
collector limitations, and evidence pack hash.

## Decision rules

| Condition | Action |
|---|---|
| Role/module absent | Mark not applicable or unavailable; do not fail host health |
| Field may contain a secret | Omit or redact; never hash as a substitute for approval |
| Fleet request | Hand off manifest to `windows-fleet-management` |

## Quality standards

Second collection with no change produces an equivalent normalised snapshot.
Every value has target, source, and timestamp context.

## Anti-patterns

- Exporting all registry keys. Fix: use allow-lists.
- Parsing table output. Fix: retain objects.
- Counting missing roles as failures. Fix: report applicability.
- Collecting usernames without purpose. Fix: minimise identity data.
- Calling a central job live proof. Fix: correlate a local snapshot.

## References

- [`docs/research/source-synthesis.md`](../../docs/research/source-synthesis.md)
- [`engine/schemas/operation-envelope.schema.json`](../../engine/schemas/operation-envelope.schema.json)
<!-- dual-compat-end -->
