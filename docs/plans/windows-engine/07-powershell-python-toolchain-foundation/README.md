# Phase 07 — PowerShell/Python toolchain foundation

## Purpose

Build the development and execution foundation that lets the engine produce reliable commands from any Windows CLI without turning scripts into unreviewed one-off automation.

## Workstreams

### 7.1 PowerShell engineering standard

Define approved verbs, naming, parameter contracts, pipeline behavior, error handling, native exit-code mapping, streams, ShouldProcess, SupportsPaging where useful, help, examples, module layout, and edition compatibility. Ban Invoke-Expression, unsafe string-built commands, silent catch blocks, hidden downloads, and unbounded parallelism.

### 7.2 Python engineering standard

Use a supported Python range, pyproject metadata, virtual environments, typed interfaces, structured logging, JSON Lines or JSON schema output, subprocess isolation, timeouts, cancellation, safe encoding, and no implicit elevation. Keep Python adapters explicit about the PowerShell or API boundary they call.

### 7.3 Toolchain

Standardise Pester, PSScriptAnalyzer, pytest, Ruff or an approved equivalent, JSON Schema validation, secret scanning, dependency lock files, SBOM generation, and reproducible builds.

### 7.4 Developer workflow

Provide commands for bootstrap, lint, unit test, contract test, fixture run, lab test, docs build, catalog regeneration, release build, and cleanup. Ensure the workflow works from PowerShell 5.1 where claimed and PowerShell 7 by preference.

## Required artifacts

- PowerShell module skeleton
- Python package skeleton
- coding and error-handling standards
- lint configurations
- test runner wrappers
- dependency and signing policy
- first clean sample cmdlet and Python adapter

## Verification

- A clean machine can bootstrap without network access when using a prepared package.
- Lint catches forbidden patterns.
- Unit tests run under the declared runtimes.
- Native process failures retain exit code, stderr, and evidence without leaking secrets.
- The same operation returns stable schema across interactive and non-interactive invocation.

## Exit gate

The foundation passes lint, unit, schema, secret, dependency, and packaging checks. At least one PowerShell-first and one Python-supporting operation demonstrate the complete authoring-to-evidence path.

## Dependencies and risks

Depends on Phases 04–06. The risk is allowing language preference to override the native management boundary. The toolchain must keep mutation ownership singular.
