# Group Policy pilot and fleet decision record

This worked example is a synthetic plan, not an executed domain change.
Route: `windows-group-policy`, with `windows-active-directory-health` for replication and
`windows-troubleshooting` when effective ownership is uncertain. Risk is R4
under the existing skill contract. Status: **BLOCKED for execution** until the
named domain, approved GPO GUID, target manifest, independent approver, change
window and tested backup are supplied. Neither an OU name nor a preview grants
authority.

The example change is one approved setting in a dedicated GPO. Its exact
before/after value must come from the approved change packet; there is no
invented tenant setting or recommended default here. Do not edit a default
domain policy or change enforcement, filtering and settings in one operation.

1. Capture domain/controller identity, replication health, the GPO GUID and
   versions, link order/enforcement, security/WMI filters, inheritance and any
   competing MDM owner. Export its report and representative client RSoP.
   Stop on conflicting owners or unhealthy replication.
2. Back up the exact GPO into the approved evidence store. Record the returned
   backup ID separately from the GPO GUID, timestamp and integrity hash; retain
   the original links and scope as a separate recovery artefact. Prove restore
   in the isolated domain before the production window. The proposed plan
   currently has no such evidence, so it remains blocked.
3. Preview the single setting and any required pilot link operation with the
   applicable cmdlet's `-WhatIf`. Review the before/after report and effective
   scope; preview cannot demonstrate client application. Have an independent
   approver accept the exact diff and recovery record.
4. Use a pilot OU with two explicitly enumerated lab computers in this example,
   one representative user context each. These counts are example design
   choices, not fleet evidence. Concurrency is one, automatic retries are zero;
   any unexpected target or verification failure stops expansion. Keep an
   unchanged comparison client outside the pilot.
5. After authorised application, check replication and client policy refresh,
   collect GPResult/RSoP, confirm the intended effective setting and application
   behaviour, and test administrative access. Confirm the comparison client's
   state did not change. Observe for the approved window; an absent measurement
   is NOT_ASSESSED, never a pass.
6. Expand only with a separately approved finite manifest, maximum host count,
   expiry, maintenance window and failure threshold. Run
   `scripts/validate_fleet_manifest.py`; it is authoritative. The JSON schema
   covers structure only and cannot check expiry, window nesting, unique targets
   or approver separation. The manifest has no canary field yet, so name the
   canary ring in the change packet. Keep per-target results and cancellation evidence. A
   successful pilot does not authorise an unbounded fleet operation.
7. On failure, stop scheduling targets, reverse only the introduced link where
   appropriate and restore the identified GPO backup under recovery authority.
   Do not use a broad restore-all operation. Restore-GPO requires the original
   domain and existing GPO; deletion/domain-loss recovery is a different plan.
   Verify restored report/version, links and effective client policy, workload
   behaviour and administrative access. Failed verification keeps status Failed
   and escalates to the recovery owner; record elapsed recovery time when run.

[Official command contract and source review](../research/currentness-2026-10-29.md)
were checked on 29 October 2026. Actual preview, canary, restore timing and
fleet execution are NOT_ASSESSED because this environment has no Windows domain.
