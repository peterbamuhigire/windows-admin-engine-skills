# Windows Kaizen final report — 29 October 2026

The two critical service defects are repaired with controlled-failure proof.
Typed wrapper arguments, diagnosis-first routing and native plugin inventory
now have automated guards. This is a bounded improvement, not Windows fleet
production certification. Target **95 is not met**.

Scores are reviewer judgements (inference), equally weighted under the Standard.
The baseline is frozen at `87116da`; raw evidence was collected at `52a2cdc`.

| Dimension | Before | After | Evidence and remaining deficiency |
|---|---:|---:|---|
| Doctrine | 60 | 60 | Existing risk/authority model retained; broad application unproved |
| Taxonomy and routing | 55 | 65 | 34/34 first rank, seven negatives; lexical oracles only |
| Skill depth | 55 | 60 | Two reusable complete plans; other domains not deeply exercised |
| Applied proof | 38 | 55 | Nine state and three wrapper checks; Windows integration unavailable |
| Standards currency | 42 | 50 | Scoped dated official-source review; 37 legacy rows still require checking |
| Output readiness | 55 | 60 | Typed wrapper and diagnosis plan; real change packets absent |
| Accessibility and inclusion | 48 | 48 | Readable text; operator/accessibility study absent |
| Production and handoff | 40 | 58 | Failure exit and verified recovery path; fleet/schema gaps remain |
| Hygiene | 55 | 65 | Native inventory and hard full/package cap; wider historical links not exhaustive |
| Safety and integrity | 45 | 58 | Refusal and failed restore tests; domain recovery unproved |

Before raw: **49.3**; after raw: **57.9**. Standard published scores are
`min(49.3,65)=49.3` and `min(57.9,65)=57.9`. The user's separate initial
publication cap is `min(49.3,45)=45`; it is not used to conceal the raw result
or assert that the engine has reached 95. No dimension is lower. Additional
fixtures preserve all original first-rank outcomes; original first-rank
measurement was recovered after freeze and is labelled as such.

## Kept changes

| Item | Commit / evidence |
|---|---|
| W1 refusal and verified recovery | `9683fd2`; real-function state fixture |
| W2 typed wrapper and failure exit | `141c7b4`; real-wrapper process fixture |
| W3 diagnosis routing | `e8e313e`; positive and owned-negative routing tests |
| W4 native inventory and immutable cap | `b2ddf50`; six packaging regression tests, native CLI inventories |
| W5 scoped currentness and worked plans | `f798f5b`; source register pointer, operations references and five added routing probes |

No experiment was reverted. Exact commands, outcomes and limits are in
[04-validation-record.md](04-validation-record.md). Baseline documentation
contains preparation-only references to temporary files; the final practitioner
outputs and corrections are retained in this evidence folder rather than
rewriting the frozen baseline.

Residual risks: the stronger fleet validator is not fully represented by its
JSON schema; bounded fleet execution and recovery are not proven; other WSA
wrappers retain their existing read-only interface. No actual AD, SMB, GPO,
IIS, Hyper-V or tenant validation occurred. Current advisory applicability to
an unknown target estate is NOT_ASSESSED. A failed recovery or missing R4
approval blocks that operation regardless of this score.
