# Architecture decision register

| ADR | Decision | Status | Review |
|---|---|---|---|
| 0001 | PowerShell owns Windows-native mutation; Python owns orchestration and validation | accepted | 2026-11-12 |
| 0002 | JSON-compatible YAML and JSON Schema are catalogue contracts | accepted | 2026-11-12 |
| 0003 | Windows PowerShell 5.1 is compatibility baseline; PowerShell 7 is preferred and separately tested | accepted | 2026-11-12 |
| 0004 | Evidence is allow-listed, redacted, versioned, and written per operation | accepted | 2026-11-12 |
| 0005 | Live capability promotion requires official source plus disposable-lab evidence | accepted | 2026-11-12 |
| 0006 | R3-R5 mutations remain blocked until recovery gates pass | accepted | 2026-11-12 |

## Reversal triggers

- Revisit ADR-0001 if a management plane exposes no safe PowerShell boundary and
  a documented API is the authoritative owner.
- Revisit ADR-0002 if the catalogue needs YAML-only features; add a pinned parser
  rather than silently accepting dialect differences.
- Revisit ADR-0003 when supported Microsoft roles and modules run consistently
  under PowerShell 7 without Windows PowerShell compatibility.
- Revisit ADR-0006 per capability after a named lab fixture proves preview,
  negative path, rollback, and post-recovery health.
