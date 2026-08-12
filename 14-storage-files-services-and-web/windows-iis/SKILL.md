---
name: windows-iis
description: Use when inventorying or diagnosing IIS sites, application pools, bindings, certificates, HTTP.sys, logs, configuration, deployment, or rollback; use windows-network-admin for path failures.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows IIS

<!-- dual-compat-start -->

## Use when

- Diagnose HTTP status, app-pool, binding, certificate, config, or log issues.
- Capture IIS state before deployment or certificate rotation.
- Plan a staged IIS change with workload verification.

## Do not use when

- Application code, database, DNS, or CA is the proven owner.
- IIS is absent or unsupported on the target.

## Inputs

Target, site/app pool, URL/host/port/protocol, expected status/content, config
scope, certificate identifier without private key, deployment owner, and rollback.

## Platform and privilege boundary

Discovery is R0. Bindings, pools, configuration, certificates, URL ACLs, and
deployment are R2/R3. Mutations are `NOT_ASSESSED` in 0.1.

## Workflow

1. Confirm IIS role and target fingerprint.
2. Capture sites, pools, bindings, config hierarchy, certificates, HTTP.sys,
   listeners, logs, events, and dependency state.
3. Reproduce with exact URL and record status, headers, timing, and correlation.
4. Attribute failure to network, TLS, HTTP.sys, IIS, app pool, application, or dependency.
5. For authorised change, validate config, stage, probe, observe, and roll back.

## Mutation, verification, and recovery

Verification uses the external URL and critical journey plus pool/service/events.
Recovery restores exact configuration and binding/certificate reference, then
repeats the external probe.

## Stop conditions

Stop on private-key export request, unowned DNS/certificate, shared binding
collision, unknown application dependency, invalid config backup, or no health probe.

## Capability contract and degraded mode

Read IIS/provider and network evidence where modules exist. Without IIS lab,
return a diagnostic/change plan and `NOT_ASSESSED` execution.

## Outputs

IIS topology, layered diagnosis, certificate expiry/reference, configuration
diff, deployment/rollback plan, probe results, and residual risk.

## Decision rules

| Evidence | Owner |
|---|---|
| No listener/binding | IIS/HTTP.sys |
| TLS name/chain/expiry failure | certificate owner |
| 503 with stopped/rapid-fail pool | pool/application branch |
| HTTP healthy but business action fails | application/database owner |

## Quality standards

Configuration validity and external outcome are separate gates. Never store
private keys, connection strings, or authentication tokens in evidence.

## Anti-patterns

- Recycling pool first. Fix: capture failure evidence.
- Replacing cert by friendly name. Fix: use validated thumbprint/chain/name.
- Testing localhost only. Fix: use client path.
- Editing applicationHost.config live without backup. Fix: staged owner-aware change.
- Blaming IIS for app errors. Fix: separate layers.

## References

- [`docs/safety-model.md`](../../docs/safety-model.md)
- [`engine/source-register.yaml`](../../engine/source-register.yaml)
<!-- dual-compat-end -->
