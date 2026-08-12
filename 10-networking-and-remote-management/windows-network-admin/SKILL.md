---
name: windows-network-admin
description: Use when diagnosing or planning Windows IP, route, DNS, firewall, proxy, VPN, port, or name-resolution work; use windows-remote-management for transport and authentication boundaries.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Network Administration

<!-- dual-compat-start -->

## Use when

- Diagnose DNS, route, listener, firewall, proxy, VPN, or interface symptoms.
- Capture a network fingerprint before remote administration.
- Plan a bounded network change with access preservation.

## Do not use when

- The network path is proved and WinRM/RDP/SSH authentication fails.
- A remote firewall or IP change lacks out-of-band recovery.

## Inputs

Source and target hosts, expected name/address/port/protocol, network context,
current session path, policy owner, maintenance window, and recovery access.

## Platform and privilege boundary

Discovery is R0. Local reversible changes are R1/R2. Remote IP, route, DNS,
firewall, proxy, certificate, and WinRM changes are R3.

## Workflow

1. Capture `Get-WseNetworkSnapshot` and exact failure time.
2. Test in order: local stack, name resolution, route, listener, firewall,
   transport, authentication, certificate/trust, proxy, application layer.
3. Record the observation that rejects each hypothesis.
4. Detect local/GPO/MDM/DSC/vendor ownership before proposing mutation.
5. For authorised change, preview, preserve current access, register timed
   recovery, change one boundary, and test from the original source.

## Mutation, verification, and recovery

Verification is end-to-end reachability plus the intended application probe,
not only local configuration. R3 requires out-of-band access or a tested timed
rollback.

## Stop conditions

Stop on ambiguous target/interface, missing recovery, unknown policy owner,
active cluster/VPN dependency, stale snapshot, or unsupported authentication.

## Capability contract and degraded mode

Read/execute diagnostics by default. Mutation needs explicit R3 authority.
Without target access, return the decision tree and required observations.

## Outputs

Network fingerprint, hypothesis table, tests and results, policy owner,
proposed change/rollback, reachability verification, and limitations.

## Decision rules

| Evidence | Next route |
|---|---|
| Name fails but address works | DNS branch |
| Route and listener work; session auth fails | Remote-management branch |
| Local listener absent | Service/workload owner |
| Policy overwrites local setting | Owning GPO/MDM plane |

## Quality standards

Use explicit addresses and ports, test IPv4/IPv6 only where claimed, and never
equate ping failure with host failure.

## Anti-patterns

- Flushing DNS first. Fix: capture evidence.
- Disabling firewall to test. Fix: inspect rule/path.
- Editing remote IP in-band. Fix: require recovery.
- Trusting one resolver. Fix: compare configured path.
- Logging credentials. Fix: record authentication mode only.

## References

- [`docs/safety-model.md`](../../docs/safety-model.md)
- [`engine/source-register.yaml`](../../engine/source-register.yaml)
<!-- dual-compat-end -->
