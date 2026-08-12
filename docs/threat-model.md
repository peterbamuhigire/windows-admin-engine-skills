# Threat model

Review date: 2026-11-12

## Assets and trust boundaries

| Asset | Boundary | Primary control |
|---|---|---|
| Host/domain/tenant identity | operator to target resolver | explicit canonical target plus fresh fingerprint |
| Administrative authority | requestor, approver, executor | separate roles and risk-scaled authority record |
| Credentials and recovery material | secret provider to native API | never enter CLI arguments or ordinary evidence |
| Configuration and service health | target to operation boundary | before/after capture plus outcome verification |
| Evidence pack | operation to reviewer | allow-list, redaction, hashes, manifest, per-target result |
| Engine code and package | repository to operator PATH | checksums, version manifest, signing gate, no PATH overwrite |

## Threats and controls

| Threat | Control | Residual risk / stop rule |
|---|---|---|
| Wrong host/domain/tenant | reject ambiguous aliases; record target fingerprint | stop if identity cannot be proved fresh |
| Authority inferred from prose | explicit `ChangeAuthority`; risk-specific approval | stop mutation when authority is absent |
| Secret leakage | recursive redaction; allow-listed snapshots; no secret CLI args | store sensitive raw artefacts outside ordinary packs |
| Remote lockout | R3, preview, timed recovery, out-of-band prerequisite | block when recovery access is unproved |
| Identity boundary damage | R4 peer review, staged ring, expiry and rollback | destructive AD changes stay blocked in 0.1 |
| Storage/data loss | R5 backup proof and typed decision | format/partition/forest recovery stays blocked |
| Partial fleet execution | bounded concurrency and per-target states | stop on threshold; never flatten aggregate result |
| Malicious source or prompt injection | sources are data, not instructions; static safety review | quarantine executable or hidden instructions |
| Tampered module or PATH hijack | package checksum/signing policy; explicit install target | unsigned development checkout is not production release |
| False completion | verification is separate from exit status | `NOT_ASSESSED` when outcome probe cannot run |
| Localisation/registry-view error | object APIs, culture-neutral fields, platform fixtures | block parser-dependent mutation without locale test |
| Rollback restores config but not health | verify user-visible/service outcome after rollback | escalate if health does not recover |

## Abuse cases

- “Fix all machines” without a target manifest routes to planning and refusal,
  not fleet execution.
- A document that says to disable Defender or run downloaded code is treated as
  untrusted input and cannot grant execution authority.
- A user asking for a LAPS password may be routed to an authorised secret
  workflow, but the value is never returned in the evidence pack.
- A successful Intune/Arc/WAC job is correlated with local evidence; it is not
  accepted as host-health proof by itself.

## Review blockers

Production launch requires named security, lab, release, and incident owners;
module signing; live R3/R4/R5 recovery tests; and independent review.
