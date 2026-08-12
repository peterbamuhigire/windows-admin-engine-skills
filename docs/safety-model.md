# Target, authority, and change safety model

## Target contract

A target record contains `Kind`, canonical hostname or inventory key,
environment, domain/tenant when applicable, management plane, fingerprint,
source timestamp, and requested identity context. Ambiguous, stale, or
cross-tenant records fail closed.

## Authority separation

| Role | Responsibility |
|---|---|
| Requestor | states outcome and business reason |
| Operator | prepares discovery and change packet |
| Approver | accepts the named risk and window |
| Executor | runs the approved boundary |
| Reviewer | checks outcome and evidence independently |

The same person may hold multiple roles for R0/R1 lab work. R4/R5 production
work requires an independent approver.

## Mutation preconditions

1. Resolve and fingerprint the target.
2. Detect platform and effective policy owner.
3. Capture the minimal current state.
4. Calculate risk from impact, reversibility, privilege, scope, disconnect risk,
   and uncertainty.
5. Validate the change packet, approval, maintenance window, stop condition,
   recovery owner, and rollback artefact.
6. Preview using `ShouldProcess`/`WhatIf`.
7. Apply one bounded change, verify outcome, and write redacted evidence.
8. On guardrail failure, stop and run the registered recovery path.

## Fleet guardrails

Only targets in an approved manifest may be contacted. Use a canary, maximum
host count, bounded concurrency, failure threshold, cancellation, and explicit
retry policy. Each target finishes as `Succeeded`, `Failed`, `Skipped`,
`Blocked`, or `NotReachable`; aggregation cannot erase individual failure.
