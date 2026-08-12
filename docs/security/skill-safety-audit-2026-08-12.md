# Skill safety audit: Windows Administration Skills Engine

Safety status: Safe for the declared 0.1 boundary; production mutation needs review.

## Inspected surfaces

- `AGENTS.md`, router, 16 catalogue specialists, and template.
- `WindowsSkills.Engine`, its tests, the Python CLI/validators, 48 direct
  commands and launchers, the PATH installer/uninstaller, CI, and source records.
- The supplied AD cookbook companion repository as a read-only source corpus.

## Findings and actions

| Finding | Evidence | Action / status |
|---|---|---|
| Cookbook examples lack production controls | Static scan of 170 `.ps1` files found no `CmdletBinding`, `SupportsShouldProcess`, `WhatIf`, explicit `ErrorAction`, or `try/catch`; one plaintext conversion | No imported code. Used only as capability and negative-test input. Closed. |
| Broad administrative surface could enable harmful change | Catalogue contains R3-R5 domains | Only one R2 service mutation exists; all R3-R5 execution is blocked or not assessed. Controlled. |
| Command tree changes user PATH | Installer proposes 51 directories and can affect resolution | Idempotent reconciliation, `ShouldProcess`, stale-path cleanup limited to the current or previously registered engine root, canonical deduplication, collision refusal, verification with rollback, the 8,191-character gate, and scoped uninstall. Controlled. |
| `.cmd` launchers use `ExecutionPolicy Bypass` for checked-in scripts | 48 launchers and dispatcher | Development convenience only; production distribution requires signed scripts. Needs review. |
| PSScriptAnalyzer unavailable | Module discovery found no PSScriptAnalyzer | `NOT_ASSESSED`; CI/release must provide a verified version. Open. |
| External source content could leak into Git | Source-ingestion guard checks ebook formats, known local-source markers, and large text | Zero findings; books are absent. Controlled. |
| Evidence may contain secrets | Operation results can contain collector values | Recursive redaction plus allow-listed collectors and hashes; synthetic secret tests remain open. Partial. |

## Static safety checks

The command scanner found no `Invoke-Expression`, remote download piped to a
shell, plaintext `SecureString` conversion, or implicit reboot in `commands/`.
No installer downloads code or adds a package source. The fleet validator
reports `contact_attempted=false`.

## Required production actions

1. Sign module, public scripts, shims, and release manifest.
2. Run PSScriptAnalyzer, secret/dependency scan, SBOM, and reproducibility gates.
3. Prove redaction with synthetic secrets and evidence tamper tests.
4. Run R3-R5 lockout, rollback, restore, and independent-review labs.

Release decision: accept the read-only/local-preview development engine; do not
authorise production R2-R5 use from this audit.
