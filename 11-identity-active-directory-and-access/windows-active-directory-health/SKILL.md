---
name: windows-active-directory-health
description: Use when assessing AD DS forest, domain, DC, DNS, time, replication, trust, FSMO, Kerberos, LDAP, or secure-channel health; use windows-identity-lifecycle for object changes.
metadata:
  portable: true
  compatible_with: [claude-code, codex]
---

# Windows Active Directory Health

<!-- dual-compat-start -->

## Use when

- Check a forest/domain/DC or replication problem read-only.
- Diagnose logon, secure-channel, trust, Kerberos, LDAP, DNS, or time symptoms.
- Capture identity-boundary evidence before a staged change.

## Do not use when

- Creating, moving, disabling, deleting, or changing membership/delegation.
- The request concerns only Entra identity with no AD DS dependency.

## Inputs

Forest/domain/DC identity, site, symptom and time, affected principals or naming
contexts using safe identifiers, delegated read credential, and evidence scope.

## Platform and privilege boundary

R0. Requires approved RSAT/AD module and appropriate directory read rights. The
current executable collector is `PARTIAL`; multi-DC lab proof is pending.

## Workflow

1. Follow the AD diagnostic order in the source synthesis.
2. Run `Get-WseAdHealth`; collect `dcdiag`/`repadmin` only with explicit scope.
3. Preserve results by DC, partner, naming context, site, timestamp, and exit code.
4. Check DNS and time before Kerberos, trust, or replication repair hypotheses.
5. Rank competing hypotheses and name the next discriminating test.

## Mutation, verification, and recovery

No identity change is authorised. Health verification requires comparable
post-action replication, DNS/time, role reachability, and affected logon/service
checks from more than one relevant location.

## Stop conditions

Stop on wrong forest/domain, stale topology, unresolved DNS/time, missing module,
secret request, single-DC evidence for a multi-DC claim, or any proposed FSMO
seizure/DC demotion/lingering-object removal during diagnosis.

## Capability contract and degraded mode

Read directory and native diagnostics. Without a domain lab or delegated access,
return a collection plan and status `NOT_ASSESSED`.

## Outputs

Forest/domain/DC inventory, role owners, replication summary, dependency state,
hypotheses, unassessed checks, and no-mutation attestation.

## Decision rules

| Evidence | Next action |
|---|---|
| DNS or time unhealthy | Repair plan stays with dependency owner |
| One replication partner fails | Collect per-partner/naming-context evidence |
| FSMO owner unreachable | Diagnose; do not seize without R5 recovery decision |
| Secure channel only | Test both endpoints and replication freshness |

## Quality standards

Names are paired with stable keys; errors stay attached to DC/partner/context;
historical sources never establish current support.

## Anti-patterns

- Running every diagnostic. Fix: scope by hypothesis.
- Parsing localised text as universal schema. Fix: retain raw evidence and stable fields.
- Seizing FSMO during diagnosis. Fix: separate R5 change.
- Blaming Kerberos before DNS/time. Fix: verify dependencies.
- Returning directory secrets. Fix: redact and use secret workflow.

## References

- [`docs/research/source-synthesis.md`](../../docs/research/source-synthesis.md)
- [`engine/source-register.yaml`](../../engine/source-register.yaml)
<!-- dual-compat-end -->
