# Test plan

## Risk and layers

| Risk | Commit/static | Local integration | Disposable lab | Release evidence |
|---|---|---|---|---|
| Catalogue/routing drift | schema, names, sections, top-three fixtures | CLI list/route | N/A | validator logs |
| Unsafe script content | source and command scanners | module import, `WhatIf` | negative target/authority cases | safety audit |
| Operation/evidence schema | Python unit tests and JSON contract | inventory pack hash/redaction | tamper and partial-host fixtures | evidence pack |
| Windows PowerShell 5.1 | AST/import/static smoke | local inventory/health/preview | Server/Server Core rows | platform matrix |
| AD/GPO/identity | structural and refusal fixtures | module-unavailable path | isolated two-DC forest | per-DC evidence |
| Network/remoting lockout | decision fixtures | local read-only state | workgroup/domain with timed recovery | rollback proof |
| Storage/recovery | destructive refusal | service state only | clean-room restore | RPO/RTO result |
| Fleet | manifest validation, no-contact fixture | planning only | mixed canary/partial failure | per-target record |

## Executed locally on 2026-08-12

- Catalogue validator: 16 specialist skills, zero findings.
- Routing smoke: 16 fixtures, zero failures.
- Source ingestion: zero findings.
- Python unittest: executed on Python 3.12.
- PowerShell smoke: Windows PowerShell 5.1 module import, local inventory, and
  EventLog stop preview; the service remained unchanged.
- Command installer preview: 51 directories, 49 discoverable `wsa*` command
  names, no collision on the development host, proposed user PATH 4,213 chars.

These are structural and one-machine results. Windows Server, PowerShell 7,
Server Core, AD, Hyper-V, IIS, non-English locale, remoting, restore, and fleet
tests remain `NOT_ASSESSED`.

## Exit rules

No test failure is waived into a baseline. An unavailable live test remains
visible and blocks promotion of that capability. Pester must run when available;
the dependency-free smoke test is not a substitute for the domain lab.
