# Phase 14 — Storage, files, services, and web workloads

## Purpose

Cover the everyday Windows server workload layer: storage, files, services, scheduled tasks, IIS, and HTTP/TLS without mixing domain responsibilities.

## Workstreams

### 14.1 Storage and filesystem

Support inventory and controlled operations for disks, partitions, volumes, NTFS, ReFS, Storage Spaces, quotas, deduplication, VSS, mount points, disk health, free space, file age, ACLs, open handles, and file locks. Formatting, resizing, and destructive cleanup are high-risk boundaries.

### 14.2 Files and shares

Cover SMB shares, share permissions versus NTFS permissions, DFS, offline files, quotas, auditing, inheritance, access-based enumeration, file screening, and safe permission analysis. Produce effective-access evidence without exposing file contents unnecessarily.

### 14.3 Services and tasks

Inventory service dependencies, recovery actions, startup type, accounts, binary paths, signatures, scheduled tasks, triggers, run-as identity, history, and failure events. Make restart/disable/start changes idempotent and health-verified.

### 14.4 IIS and web workloads

Cover IIS sites, application pools, bindings, certificates, URL ACLs, logs, configuration hierarchy, health probes, deployment handoff, and rollback. Treat application code, database, DNS, and certificate authority as separate boundaries.

## Required artifacts

- storage and filesystem skill
- file-share and ACL skill
- service and scheduled-task skill
- IIS/web workload skill
- workload health schemas
- storage and permission danger fixtures

## Verification

Test Server Core, file server, IIS host, locked file, permission inheritance, failed service dependency, expired certificate, invalid IIS configuration, full volume, VSS failure, and rollback of service/configuration changes.

## Exit gate

Read-only coverage works across supported roles, and every mutation shows preconditions, impact, rollback, and post-change health. The engine never reports permission correctness from ACL text alone without effective-access context.

## Dependencies and risks

Depends on Phases 06, 08, 09, 10, and 12. Storage and access changes can destroy availability or confidentiality; default to report-only.
