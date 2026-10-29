# Practitioner task outputs after the experiments

Date: 29 October 2026. All examples are synthetic; no Windows host was changed.

## Task 1 — pilot OU and fleet plan

The router selects `windows-group-policy`. The complete plan is now a reusable
[operations reference](../../operations/group-policy-pilot.md), linked from the
skill. It states R4, the missing execution authority, backup identity, separate
link recovery, explicit pilot/concurrency/failure bounds, effective-policy
verification and the blocked fleet decision. Its domain lab, actual preview,
restore timing and fleet evidence remain NOT_ASSESSED. This replaces no actual
customer change packet.

## Task 2 — file-share failure after patching

The exact described incident now selects `windows-troubleshooting` first.
The [complete diagnostic tree](../../operations/file-share-after-patching.md)
orders scope, transport, identity, permissions, patch applicability and bounded
repair/recovery. It distinguishes a matching build advisory from temporal
correlation. Without host evidence its conclusion is unknown cause, not an
invented patch regression. The independent fixture set now contains 34 first-rank
matches and seven owned-negative primary-route checks; this is a lexical test.

## Task 3 — preview and scope boundary

`test-service-wrapper-fixture.ps1` runs the real service wrapper/dispatcher and
state function in three child-process fixture invocations: stop with WhatIf,
already-running no-change with WhatIf, and an out-of-scope target with WhatIf.
All are non-mutating; the out-of-scope result is Failed and the process exits
nonzero before service lookup. The result/identity collector and service APIs
are explicitly replaced by synthetic functions. The companion state fixture
covers nine normal/failure/recovery assertions, including timeout and failed
restore. These counts are output from the named scripts, not Windows integration.

The prompt asks for three distinct WSA commands in WhatIf mode. There is only
one implemented mutating WSA operation; read-only wrappers do not expose the
same interface. Three invocations do not satisfy that broader request. Coverage
of three distinct mutating tools is **NOT_ASSESSED / capability gap**, deferred
rather than adding artificial mutators. The registered Windows behaviour suite
still cannot run its Windows identity checks on this Linux host.
