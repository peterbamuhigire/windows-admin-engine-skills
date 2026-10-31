# Practitioner tasks after the changes (31 October 2026)

Produced with the same command as [practitioner-before.md](practitioner-before.md)
after the K1 to K7 commits.
The router output for all three prompts is identical to the output before any
change: ranks, scores, risk classes and warnings match. No routing rule or
catalogue keyword was altered in this pass; the added fixtures pin existing
behaviour.

| Task | Before | After |
|---|---|---|
| 1. Group Policy pilot then fleet | `windows-group-policy` (10), `windows-security-analysis` (5), `windows-fleet-management` (5); R4 warning | identical |
| 2. File share after patching | `windows-troubleshooting` (4), `windows-storage-files-services` (3), `windows-patch-management` (2); no warning | identical |
| 3. Service restore on an out-of-scope host (route only) | `windows-storage-files-services` (3); R2 warning | identical |

What changed is behind the route.

- **Task 1.** The plan's fleet stage tells the operator to run
  `scripts/validate_fleet_manifest.py`. That validator now refuses a revoked
  authority, an unbounded or inverted window, a target window outside the change
  window, a wildcard or list hostname and a self-approved R4 target. The nine
  probe mutations that passed before all return one finding; the valid fixture
  and an extra-field manifest still pass (table in
  `04-validation-record.md`). The plan now says what the schema covers and what only the
  validator checks, and it tells the operator to name the canary in the change
  packet because the manifest still has no canary field.
- **Task 2.** The plan's identity step now names `windows-active-directory-health`,
  a skill that exists, and separates account or trust repair as R4 work under
  `windows-identity-lifecycle`.
- **Task 3.** Still NOT_ASSESSED: no PowerShell on this host. The refusal and the
  command run were not exercised.
