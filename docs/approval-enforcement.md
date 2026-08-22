# Approval enforcement adapter

Windows administration actions are declared in
[`approval-adapter.json`](approval-adapter.json) and use the shared contract
from `skills-web-dev/docs/approval-contract.md`, in addition to this engine's
R0-R5 safety model.

## Required change preview

Show exact target, inventory key, management owner, environment, authority,
risk class, `ShouldProcess`/`-WhatIf` output, before-state, change window,
backup or out-of-band access, command and parameter hash, per-target blast
radius, rollback, verification oracle, and residual risk.

## Gated actions

Service-state changes are L2. Remote access, identity/security policy,
firewall, destructive recovery, storage, certificates, GPO, and security-boundary
changes are L3. The shared gate does not grant Windows authority; the effective
management owner and delegated role must still be confirmed.

## Stop conditions

Stop on an unresolved hostname, domain, tenant, identity, management owner,
backup, out-of-band path, target mismatch, missing audit sink, or incomplete
per-target outcome. Never pass passwords, LAPS values, recovery keys, or
private keys as ordinary arguments or evidence. Missing lab/live evidence is
`NOT_ASSESSED`.

## Acceptance boundary

Discovery and a `-WhatIf` plan may proceed automatically. A service-impacting,
remote-access, identity, security, destructive, or recovery mutation cannot run
without the shared gate and after-state verification for every target.
