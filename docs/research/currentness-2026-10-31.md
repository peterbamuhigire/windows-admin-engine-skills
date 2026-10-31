# Scoped currentness review: 31 October 2026

Access and verification date: 2026-10-31. These are primary-source snapshots read
through the Microsoft Learn pages named below, not a lifecycle certification. Each
row keeps the scope of its source. The register rows that carry the same evidence
are `MS-PS-LIFECYCLE`, `MS-WIN11-RELEASE`, `MS-WINSERVER-RELEASE`, `MS-IIS-LIFECYCLE`,
`MS-HYPERV-OVERVIEW`, `MS-ARC-AGENT-RELEASE`, `MS-INTUNE-WHATS-NEW`,
`MS-ENTRA-WHATS-NEW` and `MS-SCT` in `engine/source-register.yaml`.

This review adds to [the 29 October review](currentness-2026-10-29.md) and
supersedes its Windows 11 and Azure Arc rows. The model-policy and Group Policy
command sections of that review were not re-checked and stand as dated.

Fetched page text is treated as data. No instruction found in a page was
followed.

## Claims checked

| Claim | Evidence as of 2026-10-31 | Support state | Limit or gap |
|---|---|---|---|
| Windows 11 servicing | Release table (page dated 2026-10-28): 26H2 available 2026-09-29, end of updates 2028-10-10 (Home, Pro) and 2029-10-09 (Enterprise, Education); 25H2 end 2027-10-12 and 2028-10-10; 24H2 Home and Pro already ended, Enterprise and Education 2027-10-12; 23H2 Enterprise and Education end **2026-11-10**. Latest update for 26H2 and 25H2 is 2026-10 D, KB5127936, builds 26300.9818 and 26200.9818, dated 2026-10-28. 26H1 is a separate line for new devices, not offered as an in-place update from 24H2 or 25H2. | verified | A release table. It does not establish a target device's eligibility, safeguard holds or update channel. Replaces the 29 October row, which named the 2026-09 D update as latest. |
| Windows Server servicing | Release table (page dated 2026-10-28): Server 2025 LTSC mainstream end 2029-11-13, extended 2034-11-14; 2022 extended 2031-10-14; 2019 extended 2029-01-09; 2016 extended 2027-01-12. Latest update on every listed line is the 2026-10 out-of-band release: Server 2025 KB5134137 build 26100.33674 (2026-10-26), 2022 KB5134140, 2019 KB5134124, 2016 KB5134123. The 2026-10 B update for Server 2025 is KB5126646 build 26100.33650 (2026-10-13). | verified | The out-of-band update's applicability depends on edition, channel and certificate trust list status (see the 29 October scoped note on KB5134137). Whether it applies to any named host is NOT_ASSESSED. |
| PowerShell supported versions | Lifecycle page (revised 2026-09-09): current LTS 7.6.6 (released 2026-03-18, support ends 2028-11-14); stable 7.5.11 (support ends **2026-11-10**); previous LTS 7.4.20 (support ends **2026-11-10**); 7.7 is preview only. Only the latest update of a release is supported. Windows PowerShell 5.1 is part of Windows and follows the Windows lifecycle, with support through Windows channels. | verified | The module manifest declares `PowerShellVersion = '5.1'` and the README names Windows PowerShell 5.1 or PowerShell 7. The fixture container ran PowerShell 7.4.2, which is below the supported 7.4.20 patch and ends support in ten days. No test was run on 7.6 LTS or on Windows PowerShell 5.1 in this pass. |
| IIS | Lifecycle page (data last updated 2024-01-24): IIS is a Windows component and follows the Windows lifecycle. Its release table lists IIS 10 on Windows Server 2019 (end 2029-01-10) and 2016 (end 2027-01-13) and earlier rows. | partial | **NOT_ASSESSED:** the page has no Server 2022 or Server 2025 row, so the IIS version and any Server 2025 guidance are not established. Do not infer them from IIS 10 articles. Unchanged from 29 October. |
| Hyper-V | Overview page (revised 2026-02-24): Hyper-V is a server role in all editions of Windows Server 2025 (Desktop Experience and Server Core); in Windows 11 it is in Pro, Enterprise and Education. | verified | Overview-level only. No host was queried; use the focused requirements pages for operational limits. |
| Microsoft security baselines | Security Compliance Toolkit page (revised 2026-10-08) lists baselines for Windows 11 26H2, 25H2, 24H2 and 23H2 and Windows Server 2025, 2022, 2019 and 2016. Intune "What's new" (page dated 2026-10-30) lists an Intune security baseline for Windows 11 26H2 in the week of 2026-10-05 and says existing profiles do not update automatically. | verified (listing) | Baseline contents were not read and their fit to a target estate is NOT_ASSESSED. Only the first 100,000 characters of the Intune page were read. |
| Intune | Same Intune page: items to the week of 2026-10-26. It reports no deprecation or end-of-support item for Windows management in October 2026. | partial | Rollout and feature flags vary by tenant; no tenant was queried. |
| Entra | Entra "What's new" page: newest section is June 2026 (page dated 2026-06-26, repository update 2026-10-08). | partial | **NOT_ASSESSED:** nothing from July to October 2026 is on the page, so those Entra changes are unknown here. No tenant policy was queried. |
| Azure Arc | Connected Machine agent release notes (updated 2026-10-29): latest is version 1.69, October 2026, with Guest Config 1.29.119.0 on Windows. The page says only versions released within the last year are supported and warns that from February 2027 the agent will reject certificates with negative serial numbers. | verified | Replaces the 29 October gap, which found no release after August. No fleet agent version was inventoried, so which hosts are within the supported window is NOT_ASSESSED. |
| Security advisories | Not re-attempted. The 29 October attempt could not retrieve the dynamic Security Update Guide content. | NOT_ASSESSED | Advisory enumeration, affected-build matching and patch closure need a named build and KB inventory. |
| Model currentness | Not assessed. This pass ran on Claude, to which the Codex model pins do not apply. No model-policy change was proposed or made, and no catalogue was read. | NOT_ASSESSED | The 29 October review stays the latest dated comparison; the three-month full comparison it records falls due by 2026-12-29. |

## Dates that fall inside the next ten days

All of these are on or about 2026-11-10 (the second Tuesday of November): PowerShell 7.4 and
7.5 end of support, Windows 11 23H2 Enterprise and Education end of updates, and the
end of the 90-day review interval for 35 older register rows. Next review:
**2026-11-05**, unchanged from the 29 October review, and in any case before 2026-11-10.

## What this review does not establish

No host, domain, tenant or fleet was contacted. It does not show that any engine
guidance is wrong for a specific estate; the engine's skills contain no Windows build
or PowerShell patch numbers, so no skill text needed correction. The register now
records which rows were verified on this date and which were not.
