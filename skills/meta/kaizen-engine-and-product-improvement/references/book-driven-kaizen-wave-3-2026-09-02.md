# Book-driven Kaizen Wave 3: Windows administration application

Use this reference for improving Windows administration skills, runbooks, diagnostics,
automation, fleet operations, and recovery.

Owning skill: [Kaizen owner](../SKILL.md).

## Transfer controls

- Resolve the target and management plane first; establish a read-only baseline with per-target
  outcomes, evidence, scope, and owner. Default to R0/read-only and require explicit escalation
  for R1-R5 actions.
- Write PowerShell and automation contracts with approved parameters, validation, explicit error
  handling, `ShouldProcess`/`-WhatIf` where applicable, bounded concurrency, transcript/logging,
  least privilege, and rollback. Never expose secrets.
- Use UNIX/process/shell lessons as mental models only: verify Windows process, service, event,
  network, identity, policy, storage, and remoting behavior with current Microsoft documentation
  and lab evidence.
- Add failure-path tests, canary/ring rollout, circuit breaker, recovery proof, and a post-change
  re-audit. For agentic workflows keep tools scoped and human approval explicit for impactful
  changes.

## Boundaries

Historical shell, UNIX, HTTP, Git, Python, bug-hunting, and agent examples are not Windows
operational authority. Do not copy unsafe command construction, exploit recipes, legacy protocol
assumptions, or broad destructive actions. Mark unavailable host/lab evidence `NOT_ASSESSED`.

## Measures and routing

Track read-only evidence completeness, per-target success, change failure, rollback success,
incident recurrence, remediation time, patch/reboot compliance, security findings, script test
coverage, and management-plane drift. Route to the narrow Windows owner, security gate,
fleet/canary, recovery, and currentness checks.

## Currentness gate

Verify PowerShell, Windows management, security, protocol, lifecycle, and policy claims against
current Microsoft/standards authorities at task time. Record source/date/freshness/support/
uncertainty and review trigger before execution.
