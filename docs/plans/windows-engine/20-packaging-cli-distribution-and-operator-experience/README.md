# Phase 20 — Packaging, CLI Distribution, and Operator Experience

## Objective

Make the engine discoverable and runnable from the CLI while preserving safety, portability, versioning, and a clear operator experience.

## Work packages

1. Define the engine command surface: router, capability discovery, skill invocation, dry-run, explain, verify, evidence, rollback, replay, and doctor commands.
2. Package PowerShell as signed modules/scripts and Python as a controlled package or embedded utility set with pinned dependencies and offline support.
3. Install shims into a user-selected scripts directory and expose them through PATH without overwriting unrelated commands.
4. Implement structured output (JSON), human-readable summaries, stable exit codes, transcript locations, correlation IDs, and redacted diagnostics.
5. Provide command completion, examples, capability-aware help, platform warnings, elevation guidance, and safe defaults.
6. Build versioned manifests and compatibility negotiation so an old manifest cannot silently invoke a changed operation.
7. Publish signed, checksummed bundles with SBOM, provenance, changelog, rollback instructions, and a removal procedure.

## Required artefacts

- CLI and PowerShell module specification;
- install/uninstall/upgrade scripts;
- command and output schema;
- signing and provenance policy;
- offline installation bundle;
- operator quickstarts; and
- package acceptance report.

## Exit gate

A clean Windows machine can install the engine, discover supported capabilities, run a dry-run, execute a safe lab operation, locate evidence, and uninstall without damaging unrelated PATH entries or user data.
