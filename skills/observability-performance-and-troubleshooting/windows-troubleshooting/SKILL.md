---
name: windows-troubleshooting
description: Use when an unexplained Windows symptom spans processes, services, events, boot, crash, hang, performance, network, or multiple subsystems; use a known domain specialist once evidence isolates ownership.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Troubleshooting

<!-- dual-compat-start -->

## Use when

- The cause is unknown or multiple components are plausible.
- Diagnose slow, high CPU/memory/I/O, crash, hang, boot, service, or intermittent behaviour.
- Select minimal Event Log, counter, ETW, Sysinternals, dump, or network evidence.

## Do not use when

- A known subsystem has a narrower specialist.
- The request jumps directly to repair or destructive cleanup without diagnosis.

## Inputs

Exact symptom, affected user/workload, first/last occurrence, target, timezone,
recent changes, reproducibility, impact, privacy limit, and safe collection window.

## Platform and privilege boundary

Diagnosis is R0. Trace/dump collection may contain sensitive data and needs
scope/retention approval. Containment and repair are separate risk-classed work.

## Workflow

1. Freeze symptom, time, target, impact, and recent-change facts.
2. Run inventory/health/events; preserve evidence before cleanup or restart.
3. List competing hypotheses with evidence for/against and confidence.
4. Choose the cheapest next test that best discriminates them.
5. Escalate to counters, WPR/WPA, Procmon, Process Explorer, ProcDump, dumps, or
   WinDbg only when filters, duration, size, privacy, and stop conditions are set.
6. Route isolated cause to the owner; verify repair against original symptom.

## Mutation, verification, and recovery

Diagnosis does not mutate. Repair starts a new change packet. Verification
reproduces the original path and observes an adequate comparison window.

## Stop conditions

Stop collection on privacy/secret exposure, unbounded trace growth, performance
impact, wrong target/time, chain-of-custody need without process, or missing disk.

## Capability contract and degraded mode

Read and bounded execution are allowed. Without target access, provide hypotheses
and discriminating evidence plan, not a confident cause.

## Outputs

Symptom record, timeline, observations, hypothesis ranking, next test, collection
manifest, privacy/retention note, owner handoff, and residual uncertainty.

## Decision rules

| Situation | Tool level |
|---|---|
| Service/event evidence discriminates | Stop; do not trace |
| Intermittent file/registry/process interaction | Filtered Procmon |
| Crash | WER/ProcDump then debugger owner |
| System-wide latency | baseline counters then targeted ETW |

## Quality standards

Every causal claim is tied to observed evidence. Performance claims state
baseline, method, interval, workload, and uncertainty.

## Anti-patterns

- Random command lists. Fix: hypothesis table.
- Restarting before evidence. Fix: preserve state.
- Capturing all Procmon events indefinitely. Fix: filters/time/size.
- Treating correlation as cause. Fix: discriminating test.
- Collecting dumps casually. Fix: privacy and retention control.

## References

- [`docs/research/source-synthesis.md`](../../../docs/research/source-synthesis.md)
- [`docs/threat-model.md`](../../../docs/threat-model.md)
<!-- dual-compat-end -->
