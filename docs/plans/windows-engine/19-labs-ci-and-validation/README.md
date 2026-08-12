# Phase 19 — Labs, CI, and Validation

## Objective

Create a disposable Windows lab and a quality system that catches unsafe, non-idempotent, platform-specific, and undocumented behaviour before release.

## Work packages

1. Define lab topologies for Windows 11, Windows Server Core, Desktop Experience, domain member, domain controller where licensed and safe, Hyper-V guest, and isolated network segments.
2. Build reusable fixtures for healthy, degraded, offline, policy-restricted, low-disk, expired-certificate, stale-credential, and partially configured systems.
3. Add unit tests for pure PowerShell/Python logic; integration tests for supported application boundaries; and end-to-end tests for operator journeys.
4. Add contract tests for help, dry-run, target refusal, elevation, idempotency, rollback, output schema, exit codes, and evidence files.
5. Run PSScriptAnalyzer, Pester, Python lint/type/security checks, dependency audits, secret scans, code signing checks, and package reproducibility checks.
6. Add fault injection for network interruption, reboot, timeout, access denied, stale state, partial batch, provider failure, and interrupted process.
7. Record platform/version coverage and quarantine flaky tests rather than hiding them.

## Required artefacts

- lab topology and rebuild instructions;
- fixture catalogue with cleanup ownership;
- CI workflow and quality thresholds;
- compatibility matrix;
- failure-injection catalogue;
- test/evidence retention policy; and
- release candidate validation report.

## Exit gate

Every released skill has automated positive and negative coverage, a disposable-target test, static analysis, and a reproducible evidence bundle. A test that cannot safely run is marked `BLOCKED`, not silently omitted.
