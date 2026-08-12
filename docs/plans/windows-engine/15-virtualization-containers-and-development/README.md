# Phase 15 — Virtualisation, containers, and development environments

## Purpose

Support the virtual and developer platforms that Windows administrators routinely manage while keeping host, guest, container, and application ownership explicit.

## Workstreams

### 15.1 Hyper-V

Inventory hosts, virtual switches, VMs, checkpoints, disks, integration services, memory, CPU, replication, networking, guest state, and backup boundaries. Treat checkpoints as temporary troubleshooting tools, not a backup strategy.

### 15.2 Failover and clustered workloads

Add cluster health, node state, role ownership, quorum, storage, network, drain, move, pause, and maintenance workflows. Require out-of-band access and workload-specific verification before node operations.

### 15.3 Containers and WSL

Cover Windows containers, Docker/Containerd where supported, image provenance, isolation mode, resource limits, volumes, networks, WSL2 distributions, integration, and security boundaries. Do not confuse a development environment with a production support contract.

### 15.4 Developer workstation packs

Provide safe setup and inventory for PowerShell, Python, Git, Visual Studio Code, .NET, Node.js, C/C++, SDKs, build tools, local IIS, databases, certificates, hosts file, WSL, and test VMs. Use manifests and no-surprise package ownership.

## Required artifacts

- Hyper-V and VM skill
- cluster operations skill
- Windows containers/WSL skill
- Windows development workstation skill
- image and dependency provenance schema
- cluster and guest recovery fixtures

## Verification

Test offline guest, failed integration service, checkpoint cleanup, insufficient Hyper-V rights, cluster node drain, quorum warning, container image mismatch, WSL integration failure, and developer environment re-run.

## Exit gate

The engine can inventory and safely diagnose the virtualization stack. Mutations remain staged and workload-aware; no skill claims guest application health from host state alone.

## Dependencies and risks

Depends on Phases 06, 08, 09, 10, 13, and 14. Host changes can affect many guests; the target and blast radius must be explicit.
