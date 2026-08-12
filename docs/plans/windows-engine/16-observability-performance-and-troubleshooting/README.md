# Phase 16 — Observability, performance, and troubleshooting

## Purpose

Give agents a disciplined route from symptom to evidence to hypothesis to safe next action, rather than generating random commands.

## Workstreams

### 16.1 Observability

Define event channels, providers, ETW traces, performance counters, WER, health endpoints, service state, log retention, collection windows, and central forwarding boundaries. Normalize timestamps and host identity.

### 16.2 Performance

Cover CPU, memory, paging, storage latency, I/O, network throughput, queueing, process/thread behavior, service dependencies, IIS request health, database handoff, and virtualization contention. Require a baseline and comparison window.

### 16.3 Diagnostic tools

Create decision trees for slow system, boot failure, application error, HTTP error, DNS failure, authentication failure, service crash, disk pressure, memory pressure, high CPU, packet loss, and intermittent remote access. Route to Event Log, PerfMon, WPR/WPA, Procmon, Process Explorer, dumps, WinDbg, network tools, or role-specific evidence only when justified.

### 16.4 Incident safety

Preserve evidence before cleanup, avoid destructive diagnostics, record chain of custody where needed, minimize collection of personal data, and distinguish observation from containment and repair.

## Required artifacts

- Windows troubleshooting skill
- observability skill
- performance-analysis skill
- symptom-to-evidence router
- diagnostic collection manifest
- time-bounded trace wrappers
- evidence privacy checklist

## Verification

Use synthetic failures for service crash, disk pressure, high CPU, broken DNS, invalid certificate, failed IIS app pool, event storm, memory pressure, and network loss. Confirm the engine produces a hypothesis-ranked report and identifies what remains unproven.

## Exit gate

An agent can collect a minimal evidence pack, state competing hypotheses, name the next discriminating test, and avoid mutation unless separately authorised. Performance claims include measurement method and baseline.

## Dependencies and risks

Depends on Phases 08–15. The main risk is collection becoming surveillance or a data dump; enforce minimization, scope, and retention.
