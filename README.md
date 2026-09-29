# Windows Administration Skills Engine

The Windows Administration Skills Engine is a safety-first library for Windows workstation, server, identity, network, security, workload, recovery, and fleet operations. Its 20 active skills route work from read-only discovery to specialist procedures, with target and management-owner checks, explicit authority, risk classification, preview, per-target outcomes, verification, and recovery. Products include operational plans and runbooks, routed PowerShell commands, redacted evidence records, catalogue and validation outputs, and portability guidance for Windows tooling.

It is for Windows system and identity administrators, endpoint and fleet managers, operators, and other Chwezi engines that need a Windows-native procedure. Its shared contracts favour read-only discovery and distinguish a documented procedure from an approved or validated change; higher-risk operations require the appropriate authority and recovery evidence.

## Installation

For Claude Code, install the native plugin:

```text
/plugin marketplace add https://github.com/peterbamuhigire/windows-admin-engine-skills
/plugin install windows-admin@chwezi-windows-admin
```

Or clone the repository and run its installer (Node.js 18 or later):

```sh
git clone https://github.com/peterbamuhigire/windows-admin-engine-skills
cd windows-admin-engine-skills
./install.sh --scope project       # macOS, Linux, or Git Bash
.\install.ps1 --scope project      # Windows PowerShell
```

## Capabilities

| Category | Skills | Coverage |
|---|---:|---|
| `backup-recovery-and-business-continuity` | 1 | Backup assessment and recovery planning |
| `fleet-hybrid-and-management-planes` | 1 | Bounded fleet work across hybrid management planes |
| `identity-active-directory-and-access` | 2 | Active Directory health and identity lifecycle |
| `inventory-health-and-diagnostics` | 2 | System inventory and health assessment |
| `meta` | 2 | Engine improvement and Windows portability doctrine |
| `networking-and-remote-management` | 2 | Windows networking and remote management |
| `observability-performance-and-troubleshooting` | 1 | Cross-component Windows troubleshooting |
| `patching-software-and-endpoint-management` | 1 | Windows updates, servicing, and patch planning |
| `policy-security-and-compliance` | 2 | Group Policy and security posture analysis |
| `storage-files-services-and-web` | 2 | Storage, files, services, and IIS workloads |
| `virtualization-containers-and-development` | 3 | Hyper-V, development workstations, and desktop end-to-end testing |
| `windows-sysadmin` | 1 | Hub for routing requests to a specialist |

## References

- [Windows Administration Skills Engine repository](https://github.com/peterbamuhigire/windows-admin-engine-skills) — capability inventory and public source repository; checked against [`AGENTS.md`](AGENTS.md), [`rules/common/core.md`](rules/common/core.md), [`engine/catalog.yaml`](engine/catalog.yaml), and the `skills/` tree.
- No external books or standards documents were consulted for this README.
