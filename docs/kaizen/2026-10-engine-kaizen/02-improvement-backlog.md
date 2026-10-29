# Selected experiments — 29 October 2026

Owner for each item: Peter Bamuhigire. Target 95 remains aspirational; score
contributions are conditional on proof, not promised points. No canonical risk
classes, identity scope or finance doctrine will change.

| ID / priority | Gap and root cause (Five Whys) | Exact change / hypothesis | Acceptance | Risk / rollback / contribution |
|---|---|---|---|---|
| W1 P0 | Early failures lack results; changed flag initialised after target access; catch assumes it exists; only happy-path tests; refusal oracle absent | Initialise state before lookup and provide explicit failure/verified recovery evidence; test remote refusal, lookup failure, mutation failure and failed restore | Real function in synthetic service fixture refuses before lookup, preview does not mutate, repeated run is unchanged, recovery is observed | Bounded service function; revert isolated commit; improves safety and applied proof |
| W2 P1 | Wrapper loses parameter names; string array becomes positional; no typed entry point; no wrapper fixture; native language semantics untested | Typed service wrapper forwards a hashtable through dispatcher, preserves WhatIf/Confirm and failed-result exit code | End-to-end wrapper fixture reaches same names/state and returns nonzero on refusal | Existing remaining generic wrappers deferred; revert isolated commit; improves production handoff |
| W3 P1 | Unknown incident routes by subsystem noun; lexical rank lacks diagnostic intent; no first-rank assertion; positives only; hub rule never executable | Small diagnostic-intent routing rule with positive/owned-negative fixtures and separate rank-one metric | Existing19 fixtures do not regress; observed file-share incident routes diagnosis first | Known-subsystem requests must remain specialised; revert rule/fixtures together; improves routing |
| W4 P1 | Files/manifest paths only checked manually; package success conflated with runtime discovery; ceiling not encoded; no negative guard; release gate incomplete | Add registered packaging/file-cap/portable-route checks, failure fixtures, README/native evidence | Both runtimes match canonical paths; full checkout and package <=5000; inflated limit/pathescape/identity mismatch rejected | No skill duplication or public submission; revert gate/docs commit; improves hygiene/handoff |
| W5 P2 | Register liveness conflated with currentness; fields sparse; sources change; dated observations not retained; release applicability missing | Add scoped official-source register notes, worked incident/GPO plans and reciprocal handoff findings | Dates, source scope, gaps and review triggers explicit; no blanket support promotion | Docs only, no target controls changed; revert documentation commit; improves currency/readiness |

Structural/full-fleet Windows validation remains next-cycle work: this Linux
host cannot establish AD/GPO/SMB/IIS/Hyper-V production behaviour. Any failed
recovery is a release blocker for that operation irrespective of score.
