# Phase 08 — Shared execution, evidence, and rollback primitives

## Purpose

Implement the common WindowsSkills.Engine behavior once so every specialist inherits consistent target checking, operation envelopes, redaction, verification, and recovery.

## Workstreams

### 8.1 Target and session services

Resolve local, CIM, WinRM, PowerShell remoting, SSH, Windows Admin Center, Graph, and other adapters through typed session objects. Record authentication mode, host identity, certificate or trust evidence, timeout, and connectivity checks.

### 8.2 Operation lifecycle

Generate operation and correlation IDs, capture start/finish time, normalize warnings and errors, support cancellation, bound concurrency, and preserve per-host outcomes. Never collapse partial success into success.

### 8.3 State capture

Provide safe before/after snapshots with allow-listed fields, redaction, hashes, diff categories, source timestamps, and policy-owner hints. Keep raw sensitive outputs outside ordinary evidence.

### 8.4 Rollback and recovery

Register rollback artifacts before mutation, verify their ownership and hash, support timed rollback for access-risk changes, and record when no rollback exists. Recovery must restore service health, not merely restore a file.

### 8.5 Evidence pack

Create a deterministic pack with manifest, engine version, catalog checksum, target fingerprint, sanitized request, approvals, command boundary, before/after state, verification, logs/events, rollback, limitations, and release verdict.

## Required artifacts

- WindowsSkills.Engine module
- operation envelope schema
- target/session classes
- redaction library
- state-diff library
- rollback registry
- evidence-pack writer and validator
- partial-fleet result schema

## Verification

Exercise local and remote success, authentication failure, timeout, unreachable host, access denied, malformed result, secret redaction, cancellation, duplicate operation ID, partial fleet failure, rollback success, rollback failure, and evidence-pack tampering.

## Exit gate

All later skills can consume the shared envelope and evidence writer without bespoke result formats. The engine can prove what ran, where, under which identity, what changed, what was verified, and what remains unassessed.

## Dependencies and risks

Depends on Phases 06 and 07. Avoid building a large framework before one operation proves the lifecycle. Keep the module small, typed, and testable.
