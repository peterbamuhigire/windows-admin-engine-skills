# Control-plane adoption

This repository is the eleventh engine registered in the shared control plane
at `C:\wamp64\www\skills-web-dev\docs\engine-control-plane.json`. Windows
host, domain, fleet, and hybrid-administration doctrine remains authoritative
in this repository.

## Local roles and commands

| Role | Responsibility | Required evidence |
|---|---|---|
| Windows router | Select the narrowest specialist from `engine/catalog.yaml` and preserve rejected-neighbour reasoning. | Ranked route, target scope, risk class, and unassessed conditions. |
| Host and fleet operator | Run approved discovery or change procedures without flattening per-target outcomes. | Target resolution, management owner, and before/after state. |
| Identity and security reviewer | Review Active Directory, Group Policy, identity, firewall, Defender, BitLocker, and audit-policy boundaries. | Authority record, redacted findings, and named verification oracle. |
| Recovery gatekeeper | Confirm backup, rollback, out-of-band access, and recovery prerequisites for R2-R5 work. | Recovery proof or an explicit `NOT_ASSESSED` release block. |

The registered thin command surface uses real engine commands: `wsa-route`,
`wsa-inventory`, `wsa-health`, `wsa-security`, `wsa-service-state`, and
`wsa-evidence-validate`. Only `wsa-service-state` is a mutation accelerator in
release 0.1.0; it remains subject to the repository's R2 authority, maintenance,
verification, and rollback contract.

## Hook and release contract

- `preflight` records the exact target or inventory key, host role, environment,
  management owner, authority boundary, risk class, stop condition, and recovery
  prerequisites.
- `context` loads `AGENTS.md`, the routed specialist, `engine/platform-matrix.yaml`,
  applicable current-source evidence, and known per-target limitations.
- `before_write` requires `ShouldProcess` or `-WhatIf` where supported, captures
  before-state, confirms the change window, and checks backup or out-of-band
  access for the assigned risk class.
- `after_write` preserves every target outcome, captures after-state, runs the
  specialist's verification oracle, and checks evidence redaction.
- `release` requires target, authority, management-owner, verification, recovery,
  and residual-risk evidence. Missing live or lab evidence is `NOT_ASSESSED`,
  never `PASS`.
- `stop` preserves the last safe state, failed target set, rollback status,
  unresolved evidence gaps, and the next accountable owner.

The shared control plane coordinates ownership and handoffs. It does not grant
authority for a Windows mutation or override this engine's safety model.

## Human approval adapter

Windows mutation controls are detailed in
[`approval-enforcement.md`](approval-enforcement.md) and catalogued in
[`approval-adapter.json`](approval-adapter.json). The shared gate supplements,
but never replaces, target authority, management-owner detection,
`ShouldProcess`, recovery, and per-target verification.
