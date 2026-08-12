---
name: windows-remote-management
description: Use when diagnosing WinRM, CIM, PowerShell remoting, SSH, RDP health, authentication, trust, delegation, or constrained endpoints; use windows-network-admin for network-path failures.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Remote Management

<!-- dual-compat-start -->

## Use when

- WinRM/CIM/PowerShell remoting transport or authentication fails.
- Choose a local, domain, workgroup, SSH, JEA, WAC, or API boundary.
- Record session identity, delegation, encryption, timeout, and endpoint policy.

## Do not use when

- DNS, route, listener, or firewall reachability is not yet proved.
- The request is to retrieve or expose credentials.

## Inputs

Canonical target, source host, transport, authentication method, endpoint,
trust evidence, identity, expected command, timeout, and disconnect recovery.

## Platform and privilege boundary

Diagnostics are R0. Enabling/configuring remoting, firewall, trusted hosts,
CredSSP, delegation, certificates, or endpoints is R3/R4 and blocked in 0.1.

## Workflow

1. Prove network path and target identity.
2. Inspect listener, service, endpoint, certificate, authentication, and policy.
3. Distinguish transport, authentication, authorisation, delegation, and command failure.
4. Prefer Kerberos in a correctly configured domain; never broaden TrustedHosts
   as a generic fix.
5. Use JEA or a constrained endpoint when a narrow task can replace broad admin.

## Mutation, verification, and recovery

Any configuration change needs preview, out-of-band access, timed recovery, and
a new session verification from the original source. Existing session survival
does not prove future access.

## Stop conditions

Stop on identity mismatch, certificate failure, unapproved delegation, workgroup
trust ambiguity, inaccessible recovery path, or cross-tenant uncertainty.

## Capability contract and degraded mode

Read diagnostics only by default. Without both ends of the connection, produce
a two-sided collection plan and leave cause unassessed.

## Outputs

Session-boundary record, layered failure classification, endpoint/policy state,
tested command outcome, disconnect risk, and recovery proof.

## Decision rules

| Condition | Action |
|---|---|
| TCP path fails | Return to network skill |
| Kerberos SPN/time/DNS mismatch | Route to AD health |
| Broad admin only for one task | Design JEA endpoint |
| Workgroup trust unresolved | Block mutation |

## Quality standards

Record who executed what on which canonical target through which protected
transport. Never use successful session creation as workload verification.

## Anti-patterns

- Adding `*` to TrustedHosts. Fix: establish identity/trust.
- Enabling CredSSP casually. Fix: justify delegation risk.
- Reusing hidden sessions. Fix: record explicit session identity.
- Testing only locally. Fix: verify from source host.
- Returning credential material. Fix: use approved secret provider references.

## References

- [`docs/threat-model.md`](../../docs/threat-model.md)
- [`engine/source-register.yaml`](../../engine/source-register.yaml)
<!-- dual-compat-end -->
