# Phase 13 — Patching, software, and endpoint management

## Purpose

Manage software and update state with clear ownership, scheduling, reboot control, and fleet evidence.

## Workstreams

### 13.1 Patch discovery

Collect OS build, update history, pending updates, supersedence, failed updates, servicing stack status, reboot state, maintenance configuration, and workload role. Distinguish security, quality, feature, driver, firmware, and application updates.

### 13.2 Patch execution

Define preview, approval ring, maintenance window, download/install/reboot stages, prechecks, post-reboot readiness, rollback or uninstall boundary, and failure escalation. Never reboot a production host implicitly.

### 13.3 Software lifecycle

Inventory installed software, versions, publishers, install sources, services, scheduled tasks, drivers, package managers, WinGet boundaries, MSI/EXE evidence, and orphaned software. Build safe install, update, repair, and uninstall workflows only where ownership and rollback are clear.

### 13.4 Endpoint management

Separate local script, GPO, Intune/MDM, Configuration Manager, Windows Update for Business, Azure Arc, and third-party endpoint tools. Avoid competing control loops.

## Required artifacts

- patch-management skill
- software-inventory skill
- endpoint-management adapter
- maintenance-window contract
- reboot and readiness state machine
- patch ring and fleet result schema

## Verification

Test no-op host, failed update, pending reboot, offline host, metered connection, service role, cluster role, update conflict, rollback/uninstall, partial fleet, and post-reboot verification.

## Exit gate

The engine reports patch state and software ownership accurately, can run a bounded test ring, and preserves per-host outcomes. “Up to date” is never claimed without a defined source, scope, timestamp, and verification method.

## Dependencies and risks

Depends on Phases 05, 06, 08, 09, and 12. Reboot and servicing failures are the dominant operational risks; recovery and role-aware health are mandatory.
