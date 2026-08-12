---
name: windows-development-workstation
description: Use when inventorying or planning a repeatable Windows developer workstation with PowerShell, Python, Git, SDKs, WSL, certificates, and test VMs; use patch-management for general endpoint updates.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Development Workstation

<!-- dual-compat-start -->

## Use when

- Baseline or reproduce a Windows developer toolchain.
- Plan approved PowerShell, Python, Git, .NET, Node, WSL, SDK, or VM installation.
- Detect drift, ownership, PATH collision, or architecture mismatch.

## Do not use when

- Provisioning a production server.
- Installing packages without a manifest, owner, source, version, and removal path.

## Inputs

User/workstation, required workloads and versions, architecture, package owner,
source policy, offline needs, PATH policy, certificates, disk budget, and rollback.

## Platform and privilege boundary

Inventory is R0. User-scope installs and PATH changes are R1; system-wide
drivers/features/virtualisation are R2/R3. Installation is unvalidated in 0.1.

## Workflow

1. Inventory existing runtime, architecture, PATH, package managers, SDKs, WSL, and VMs.
2. Resolve required versions from project manifests rather than newest-by-default.
3. Choose one owner per tool; verify publisher, package, hash/signature, and licence.
4. Preview user/system changes, disk use, PATH additions, restart/reboot, and removal.
5. Install in an approved ring; run project-specific smoke tests; repeat for idempotence.

## Mutation, verification, and recovery

Verify actual compiler/runtime/project commands, not only package presence.
Rollback removes only owned entries and restores the prior PATH/config snapshot.

## Stop conditions

Stop on unverified download, package-name ambiguity, PATH collision/overflow,
architecture mismatch, admin request without need, or missing uninstall owner.

## Capability contract and degraded mode

Read local inventory. Mutation needs approved manifests and installer adapters;
otherwise produce a reproducible plan with `BLOCKED` execution.

## Outputs

Toolchain manifest, ownership/source/version matrix, PATH delta, install/removal
plan, project smoke results, idempotence result, and limitations.

## Decision rules

| Condition | Action |
|---|---|
| Project pins version | Honour project pin |
| Two package owners installed | Select owner and plan migration |
| User-scope satisfies need | Avoid elevation |
| PATH would exceed safe length | Use dispatcher/shim directory |

## Quality standards

No remote-script piping, surprise packages, hidden profile edits, or shared PATH
overwrite. The setup is rerunnable and removable.

## Anti-patterns

- Installing latest everything. Fix: project manifest.
- Adding duplicate PATH entries. Fix: canonicalise and deduplicate.
- Trusting package name alone. Fix: verify publisher/source.
- Editing all profiles. Fix: named owner and minimal scope.
- Declaring install from package exit. Fix: run project smoke.

## References

- [`docs/research/source-synthesis.md`](../../../docs/research/source-synthesis.md)
- [`docs/safety-model.md`](../../../docs/safety-model.md)
<!-- dual-compat-end -->
