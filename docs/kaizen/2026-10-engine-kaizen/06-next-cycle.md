# Next cycle and cross-engine handoffs

Owner: Peter Bamuhigire. Re-audit date: **5 November 2026**, before any Windows
fleet mutation. Keep the current engine operational within its proven scope.

| Priority | Open finding | Next bounded experiment and acceptance |
|---|---|---|
| P1 | `engine/schemas/fleet-target-manifest.schema.json` does not enforce all authority/nonempty target controls in `scripts/validate_fleet_manifest.py` | Add paired accepted/refused fixture manifests, align schema without weakening validator; require both to refuse missing authority and ambiguous targets |
| P1 | Actual Windows identity/service integration, fleet window/canary and timed restore absent | Use an approved isolated Windows VM and one disposable service; rerun preview, repeated run, controlled failure and verified recovery before expanding |
| P1 | GPO/AD/SMB and tenant proof absent | One approved isolated domain pilot with exact backup ID and separately recorded link recovery; retain effective client-state and restoration evidence |
| P1 | Current security advisory applicability unknown | Inventory named target builds/KBs and correlate official advisories; verify one applicable fix and its recovery in the isolated canary |
| P2 | Domain-specific portable contracts and broad example depth incomplete | Migrate one specialist after practitioner use, with three positive and two owned-negative fixtures |
| P2 | Three distinct mutating WSA tools do not exist | Keep honest capability boundary; add another mutator only against a real operational requirement and safety proof |
| P2 | Legacy source rows and metadata freshness incomplete | Verify one volatile claim at a time; retain exact source scope and expiry without blanket date updates |

## Reciprocal boundary records

Resolve engine names through the catalogue; these are identifiers, not relative
links into sibling checkouts. No other engine was edited in this cycle.

- Windows `docs/safety-model.md` and Linux `AGENTS.md`/`linux-sysadmin/SKILL.md`:
  Windows uses R0–R5 and ShouldProcess; Linux uses preview-first procedures.
  Preserve domain-specific classes. Shared handoffs must carry named targets,
  authority, before/after, rollback and NOT_ASSESSED labels rather than equate
  a Linux fixture with Windows integration. Semantic parity remains unassessed.
- Windows `engine/source-register.yaml` references development
  `docs/source-registers/skills-engine-currentness-2026-09.json`; its broad
  portfolio pointer cannot certify this module's Windows target support. The
  new local scoped review supplements it without editing development doctrine.
- Windows `commands/_lib/Invoke-WsaCommand.ps1` and coordination
  `hooks/destructive-command-guard.js`: shell-hook interception is not evidence
  that the PowerShell module enforced its target boundary. Coordination must
  verify its actual hook path and invocation coverage in its own cycle; Windows
  retains the independently tested in-module refusal.

The smallest next experiment is the paired fleet-manifest negative test, then
one approved Windows service restore. No wider fleet release should precede
those checks.
