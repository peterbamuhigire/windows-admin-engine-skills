# Phase 06 — Safety, target authority, and change control

## Purpose

Make safe operation a system property. An AI agent must not be able to guess a target, infer approval, silently elevate, or turn a diagnostic request into a mutation.

## Workstreams

### 6.1 Target resolution

Require explicit target kind, hostname or approved inventory key, environment, tenant/subscription when relevant, domain, identity context, and freshness timestamp. Reject aliases that resolve to multiple machines or stale inventory without confirmation.

### 6.2 Authority

Separate requestor, operator, approver, executor, reviewer, and system identity. Require stronger approval for identity, firewall, policy, storage, security controls, reboot, domain, cluster, certificate, and production changes.

### 6.3 Risk classification

Implement R0–R5 risk classes from the root plan. Risk must be computed from impact, reversibility, access/disconnect risk, scope, privilege, and uncertainty—not just command name.

### 6.4 Change packet

Every mutation begins with a change plan containing target, reason, desired state, current state, preconditions, dependencies, blast radius, maintenance window, approval, rollback, verification, and stop conditions.

### 6.5 Human and agent controls

Use ShouldProcess/WhatIf, explicit confirmation flags, timed rollback for remote lockout risk, maximum host counts, bounded concurrency, cancellation, and fail-closed behavior. Never accept passwords or recovery keys through ordinary command-line arguments.

## Required artifacts

- target contract
- authority and approval matrix
- risk classifier
- change-plan and rollback-plan templates
- safe-operation decision table
- destructive-operation refusal fixtures
- sensitive-data and redaction policy

## Verification

Test wrong target, ambiguous name, stale inventory, insufficient rights, suspended identity, missing approval, denied WhatIf, connection loss, partial fleet failure, cancellation, reboot pending, and rollback timeout.

## Exit gate

The engine refuses production or ambiguous targets by default, preserves read-only discovery, and produces a machine-checkable reason for every refusal. A security reviewer signs off the lockout and data-loss paths.

## Dependencies and risks

Depends on Phases 01, 04, and 05. A generic “Are you sure?” prompt is not a control; the system must demand the missing decision that matters.
