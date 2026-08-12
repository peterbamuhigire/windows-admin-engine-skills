---
name: windows-fleet-management
description: Use when planning bounded multi-host, canary, Intune, Entra, Arc, WAC, WinRM, CIM, drift, or mixed-management-plane work; use a domain specialist for the per-host operation.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Fleet Management

<!-- dual-compat-start -->

## Use when

- A task targets multiple hosts, sites, tenants, rings, or management planes.
- Plan preview, canary, concurrency, failure threshold, retry, or drift collection.
- Correlate central jobs with local outcome evidence.

## Do not use when

- One host is the complete target.
- “All machines” has no approved target manifest and blast-radius limit.

## Inputs

Signed target manifest with host/device ID, tenant/site/environment/owner,
platform, management plane, risk tier, window, reachability, canary, concurrency,
failure threshold, authority, and per-host specialist operation.

## Platform and privilege boundary

Fleet discovery is R0/R1 depending on evidence writes. Fleet mutation inherits
the per-host risk and is at least R3/R4. All fleet mutation is `NOT_ASSESSED`.

## Workflow

1. Validate manifest identity, freshness, ownership, tenant, and allow-list.
2. Select adapter by authoritative management plane and declare auth/rate limits.
3. Preview every target; reject targets outside manifest or maintenance window.
4. Execute canary with bounded concurrency and circuit breaker.
5. Compare central job ID with local verification; stop on threshold.
6. Expand by ring, preserve per-target states, and retry only retry-safe failures.

## Mutation, verification, and recovery

Rollback uses the same bounded manifest and per-host owner. A central “success”
never replaces local workload verification. Partial completion stays partial.

## Stop conditions

Stop on cross-tenant ambiguity, stale manifest, unknown plane owner, target-count
overflow, canary failure, rate limit, auth drift, window expiry, or cancellation.

## Capability contract and degraded mode

Read/validate manifest and plan locally. No fleet contact or mutation until an
adapter and disposable mixed-fleet lab pass; return `BLOCKED` otherwise.

## Outputs

Validated manifest, adapter/authority record, preview, canary result, per-target
states, aggregate summary, failure/retry/rollback decisions, and contact proof.

## Decision rules

| Condition | Action |
|---|---|
| Target not in manifest | Never contact |
| Failure threshold met | Open circuit and stop ring |
| Central/local evidence conflicts | Mark failed or unassessed; investigate |
| Non-idempotent failure | Do not automatic retry |

## Quality standards

Bounded concurrency, cancellation, tenant isolation, per-target evidence, and
local outcome verification are mandatory.

## Anti-patterns

- Expanding wildcard inventory. Fix: signed allow-list.
- Running full fleet before canary. Fix: rings.
- Flattening errors. Fix: per-target schema.
- Retrying every failure. Fix: classify retry safety.
- Trusting console success. Fix: local probe.

## References

- [`docs/safety-model.md`](../../docs/safety-model.md)
- [`docs/threat-model.md`](../../docs/threat-model.md)
<!-- dual-compat-end -->
