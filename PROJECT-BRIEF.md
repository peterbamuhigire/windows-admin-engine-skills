# Project brief

## Decision and audience

Build a Windows administration engine that Peter Bamuhigire and authorised
operators or agent runners can use to diagnose and change heterogeneous Windows
machines without guessing target, authority, platform, or completion.

## Success criteria

- A request routes to the correct specialist in the top three for every checked
  fixture, including near-neighbour and unsafe prompts.
- Every specialist declares target, platform, privilege, discovery, mutation,
  verification, recovery, evidence, and stop contracts.
- A local Windows host produces a versioned, redacted inventory and health
  evidence pack without mutation.
- An R2 service-state operation supports preview, explicit authority,
  before/after capture, verification, and rollback attempt.
- Unsupported or untested AD, GPO, MDM, fleet, cluster, and restore behaviour is
  reported as `BLOCKED` or `NOT_ASSESSED`, never as supported.
- Catalogue, link, source-ingestion, routing, Python unit, and PowerShell static
  gates pass on a clean checkout.

## First-release scope

The first release covers control-plane validation, local read-only inventory,
role-aware health, network/event/security/storage/workload discovery, AD health
workflow routing, evidence generation, and one bounded local service change.

## Non-goals for 0.1

- Universal support for every Windows edition, Microsoft cloud, or third-party
  product.
- Autonomous production mutation, reboot, credential rotation, forest recovery,
  DC promotion/demotion, GPO enforcement, disk formatting, or fleet-wide repair.
- Treating central-console success, a registry value, or process exit as proof of
  workload health or compliance.

## Owners

| Responsibility | Owner |
|---|---|
| Product and repository | Peter Bamuhigire |
| Engineering, security review, lab, release, incident | Assign before production launch |

An unassigned production role is a launch blocker, not implicit ownership.
