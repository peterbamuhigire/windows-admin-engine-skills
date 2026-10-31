# Practitioner tasks: router output before any change (31 October 2026)

Produced with `PYTHONPATH=python python3 -X utf8 -m windows_admin.cli --repo . route "<prompt>" --json`
at `8d6faea`. The router is lexical and deterministic; it selects a skill, it
does not run anything.

## Task 1: Group Policy pilot then fleet

Prompt: `Plan a Group Policy change that sets a registry-based security setting: first on a pilot OU of 5 machines, then across the whole fleet of 400 domain-joined machines`

| Rank | Skill | Score | Risk | Reasons |
|---:|---|---:|---|---|
| 1 | `windows-group-policy` | 10 | R4 | phrase:group policy, category:policy |
| 2 | `windows-security-analysis` | 5 | R0 | token:security, category:security |
| 3 | `windows-fleet-management` | 5 | R4 | token:fleet, category:fleet |

Warning printed: `R4 mutation: explicit target, authority, preview, verification, and recovery are required.`

## Task 2: file share after patching

Prompt: `Domain-joined machines cannot reach the file share after patching last night, cause unknown`

| Rank | Skill | Score | Risk | Reasons |
|---:|---|---:|---|---|
| 1 | `windows-troubleshooting` | 4 | R0 | intent:diagnose-before-repair |
| 2 | `windows-storage-files-services` | 3 | R2 | token:share |
| 3 | `windows-patch-management` | 2 | R2 | category:patching |

No warning (diagnosis is R0, no mutation word).

## Task 3: service restore with an out-of-scope host (route only)

Prompt: `Restart the Spooler service on host OUTSIDE-FIXTURE with -WhatIf preview`

| Rank | Skill | Score | Risk | Reasons |
|---:|---|---:|---|---|
| 1 | `windows-storage-files-services` | 3 | R2 | token:service |

Warning printed: `R2 mutation: explicit target, authority, preview, verification, and recovery are required.`

The command run and the target refusal are NOT_ASSESSED: no PowerShell on this
host.
