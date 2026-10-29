# File-share access failure after patching

Request: domain-joined machines cannot reach a file share after patching.
Route: `windows-troubleshooting` first; then identity, networking or storage
according to the evidence. Temporal proximity to a patch does not establish
causation. This is the complete diagnostic plan for the described incident;
no logs or target inventory were supplied, so there is no diagnosed cause.

1. Establish affected computers/users, exact UNC resource, first failure time,
   error text, patch/build and reboot state. Compare one affected and one
   unaffected machine using the same authorised account/resource. Preserve
   event timestamps and redact identities in handoffs. Bound collection to the
   incident window; do not export credentials or unrestricted event archives.
2. Check name resolution for the file-server name, then route and TCP 445
   reachability. A DNS failure routes to networking; a TCP failure requires
   inspection of the specific route/firewall/server listener. Successful TCP
   connection alone does not prove authentication or share access.
3. If transport works, inspect time synchronisation, domain reachability,
   secure-channel and Kerberos evidence. Compare access using the normal
   server name; accessing by IP is not an equivalent authentication test.
   Route a proved identity problem to `windows-identity-ad`. Do not reset the
   machine trust, purge sessions or change credentials before preserving proof.
4. If identity succeeds, inspect the exact share and NTFS permissions, effective
   access for the affected principal, SMB client/server events and negotiated
   security requirements. Route a proved share/service fault to
   `windows-storage-files-services`. Do not enable SMB1 or disable signing,
   authentication or the firewall as a diagnostic shortcut.
5. Compare affected/unaffected build, installed update, policy and restart state
   with official release health and advisory applicability. A known issue must
   match the actual build and symptoms. If evidence remains ambiguous, provide
   the competing hypotheses and next discriminating read-only check; do not
   label the patch as the root cause.
6. Select one authorised repair on a named canary only after causal evidence.
   Capture before-state and its inverse, preview the exact operation, preserve
   out-of-band access and stop on unexpected scope. Update removal requires
   product-specific removability and recovery proof; it is not the default.
7. Verify the original user's resource access plus authentication/security
   controls, compare the unaffected client and observe for the approved window.
   On failure, reverse the single bounded change and verify the original state;
   failed restoration blocks expansion and escalates. Retain error, target,
   timestamps, before/after and recovery evidence in the handoff.

No Windows/SMB integration or repair was executed. The routing fixture proves
selection of the diagnosis skill, not the correctness of an unobserved cause.
