# Phase 18 — Fleet, Hybrid, and Management Planes

## Objective

Extend the engine from one workstation or server to controlled fleet operations across on-premises Windows, Windows Server, Azure Arc, Intune, Entra ID, Windows Admin Center, and approved third-party management planes.

## Work packages

1. Define a target inventory contract: hostname, device ID, tenant, site, environment, owner, platform, reachability, management plane, maintenance window, and risk tier.
2. Build adapters for WinRM/CIM, PowerShell remoting, WAC, Intune, Azure Arc, Entra, and offline execution. Each adapter declares capability, authentication, rate limits, and evidence quality.
3. Implement preview, batching, concurrency limits, canaries, maintenance-window checks, circuit breakers, and stop-on-threshold failure.
4. Add drift detection for configuration, policy, software, certificates, local administrators, firewall posture, and service state.
5. Correlate local evidence with central job IDs without treating a central “success” status as proof of local health.
6. Support partial completion: every target gets `SUCCEEDED`, `FAILED`, `SKIPPED`, `BLOCKED`, or `NOT_REACHABLE` with a reason and retry policy.
7. Add cross-tenant and wrong-collection guards, least-privilege checks, and explicit production/change-ticket gates.

## Required artefacts

- management-plane capability matrix;
- fleet target manifest and ownership proof;
- concurrency and blast-radius policy;
- canary and rollback runbook;
- per-target and aggregate evidence reports; and
- adapter contract tests using disposable endpoints.

## Exit gate

The engine can safely preview and execute a bounded change against a mixed lab fleet, demonstrate partial failure and retry, and prove that no target outside the manifest was contacted.
