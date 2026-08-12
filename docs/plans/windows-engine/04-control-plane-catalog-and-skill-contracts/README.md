# Phase 04 — Control plane, catalog, and skill contracts

## Purpose

Create the Windows equivalent of the Linux routing hub and authoring discipline before adding dozens of specialist files.

## Workstreams

### 4.1 Router

Create windows-sysadmin as the default entry skill. It must classify:

- local versus remote versus fleet scope;
- workstation versus server versus domain controller;
- discovery versus diagnosis versus mutation versus recovery;
- network, identity, security, storage, workload, automation, or compliance domain;
- PowerShell-native versus Python orchestration work; and
- the correct companion engine when the request crosses software engineering, SRS, finance, research, or proposal boundaries.

### 4.2 Catalog

Create a machine-readable catalog with stable skill ID, path, category, trigger, exclusions, dependencies, platforms, risk class, script tier, references, test fixtures, source freshness, maturity, owner, and last verified date.

### 4.3 Portable skill contract

Every SKILL.md must contain frontmatter, acknowledgement, positive and negative triggers, inputs, ordered workflow, stop conditions, recovery, capability and permission contract, degraded mode, quality standards, anti-patterns, outputs, evidence, decision rules, and direct references.

### 4.4 Generated surfaces

Generate README listings, routing index, script inventory, platform matrix, and source coverage views from the catalog. Do not maintain duplicate hand-edited inventories.

## Required artifacts

- AGENTS.md
- windows-sysadmin/SKILL.md
- catalog schema and catalog
- skill template
- reference template
- evidence-pack schema
- routing fixtures
- validation command
- active-count and link checks

## Verification

- Positive prompts route to the expected specialist in the top three.
- Neighbour prompts route away from Windows when appropriate.
- Ambiguous prompts stop for discovery.
- Production and destructive prompts refuse or request authority.
- A malformed skill fails the validator.
- A skill with a broken local reference fails the gate.
- A source-only claim is not promoted to supported behaviour.

## Exit gate

The router, catalog, schema, fixture suite, and authoring validator pass on a clean checkout. At least three example specialist skills demonstrate the contract: one read-only, one reversible mutation, and one blocked capability.

## Dependencies and risks

Depends on Phases 01–03. The risk is creating a polished catalogue with weak routing. Contract tests and negative fixtures are more important than the number of skill directories.
