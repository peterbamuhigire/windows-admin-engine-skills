# Phase 09 — Inventory, health, and diagnostics

## Purpose

Deliver the first useful read-only product: a trustworthy picture of a Windows environment that later skills can consume without repeating unsafe discovery.

## Workstreams

### 9.1 Inventory

Collect OS/build/edition, PowerShell and Python versions, architecture, roles/features, hardware, disks/volumes, network interfaces, routes, DNS, services, scheduled tasks, installed software, drivers, certificates, firewall profiles, local groups, security products, pending reboot, uptime, and management-plane indicators.

### 9.2 Health

Define role-aware health checks for boot, services, storage capacity, event errors, time sync, DNS, certificates, Defender, updates, backups, replication, IIS, Hyper-V, clusters, and endpoint resources. A missing role must be reported as not applicable, not failed.

### 9.3 Diagnostics

Provide read-only collectors for Event Log, Windows Error Reporting, PerfMon counters, process/service state, network reachability, DNS, certificates, and relevant Sysinternals traces. Collection must be minimized, time-bounded, redacted, and explain what it cannot prove.

### 9.4 Baselines

Create inventory and health schemas, snapshots, drift comparison, trend views, and a machine-readable finding model with severity, confidence, evidence, owner, and next action.

## Required artifacts

- windows-system-inventory skill
- windows-health-assessment skill
- windows-event-logs skill
- platform fingerprint
- health-check registry
- diagnostic bundle schema
- sample workstation, server, and Server Core evidence packs

## Verification

Test local, remote, Server Core, non-admin, unavailable collector, localized output, stale data, hidden sensitive fields, and mixed fleet collection. Confirm collection itself does not change state.

## Exit gate

The engine can inventory one host, a bounded set of hosts, and an intentionally unreachable host; distinguish healthy, unhealthy, unsupported, and not assessed; and produce structured evidence without secrets.

## Dependencies and risks

Depends on Phases 05 and 08. The risk is reporting counts without context. Every finding needs scope, source, timestamp, confidence, and a verification path.
