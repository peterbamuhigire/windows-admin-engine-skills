# Windows October Kaizen scope — 29 October 2026

Repository `peterbamuhigire/windows-admin-engine-skills`, initial commit
`52a2cdc6e29dfd493fbd83f68ebcf64c41439588`, clean checkout, no policy edits to
preserve. Pulled before this cycle; branch `kaizen/2026-10` created. Git status
and the latest 20 commits were inspected. The user authorises commits and push
to main after review. No Windows host, domain, tenant or fleet mutation is in scope.

Read the router, core rules, hub, Kaizen, Group Policy and troubleshooting
skills; September and August audit preparation and the Portfolio Standard and
currentness gate. Requested July upgrade and continuous-improvement folders
are absent. Their evidence is NOT_ASSESSED, not reconstructed.

The three baseline tasks and complete observed route/fixture outputs are in
[practitioner-before.md](practitioner-before.md). The before score and exact
validator outcomes are in [01-baseline-scorecard.md](01-baseline-scorecard.md).
The available PowerShell runtime is a disposable Linux container; unsupported
Windows identity APIs prevent the registered Windows behaviour suite. A focused
synthetic service fixture can test the real state-transition function with
explicitly substituted OS collectors/result identity, without claiming Windows
integration or a production rollback.

| Severity | Defect | Location at baseline |
|---|---|---|
| Major | Named service parameters become positional strings before binding | `commands/storage/services/wsa-service-state.ps1:1`, `commands/bin/wsa.ps1:4`, `commands/_lib/Invoke-WsaCommand.ps1:33` |
| Critical | Early service failure cannot produce structured refusal because changed state is uninitialised | `powershell/WindowsSkills.Engine/Public/Invoke-WseServiceState.ps1:19` |
| Critical | Mutation exceptions do not reliably attempt and verify restoration; timeout rollback is attempted but unverified | Same function, lines14–19 |
| Major | Cross-component unknown-cause file-share incident ranks storage before troubleshooting | `python/windows_admin/router.py:25`, hub routing contract |
| Major | No automated hard file ceiling or native manifest-parity guard | `scripts/validate_engine.py` |
| Minor | Router contains device-specific sibling bindings | `AGENTS.md` currentness and craft routes |

Native baseline plugin tests: Codex0.165.0 installs and emits20/20 declared
skill paths; Claude2.1.312 installs and inventories21 components including its
legacy command. Public directory acceptance and hook behaviour NOT_ASSESSED.
