# Scoped currentness and model review — 29 October 2026

Access/review date: 2026-10-29. These findings are primary-source snapshots, not a full lifecycle certification. Where release scope is regional, preview, phased, service-specific or tenant-dependent, preserve that scope.

## Windows and Microsoft management stack

| Claim checked | Evidence as of access date | Support boundary / gap |
|---|---|---|
| Windows 11 servicing | Microsoft’s release table lists Windows 11 version 26H2 and a General Availability Channel 2026-09 D update dated 2026-09-29. [Release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information). The 26H2 issue page says general availability began 2026-09-29 and rollout is phased. [26H2 known issues](https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-26h2). | Snapshot does not establish tenant/device eligibility or all safeguard holds; assess target build and update channel before operational guidance. |
| Windows Server servicing | Release table lists Server 2025 LTSC; the final root recheck supersedes preparation: the table lists 2026-10 OOB, dated 2026-10-26, build 26100.33674. [Windows Server release information](https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info). | Page is rolling and can change; target edition/channel/hotpatch eligibility must be matched. Lifecycle dates on the page differ by locale rendering; do not copy dates without checking canonical lifecycle record. |
| IIS on Server 2025 | Microsoft’s IIS lifecycle page says IIS component follows the underlying Windows lifecycle but the surfaced lifecycle table did not establish an unambiguous Server 2025-to-IIS-version mapping. [IIS lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/internet-information-services-iis). | **Gap / NOT_ASSESSED:** current IIS feature/version mapping and Server 2025-specific operational guidance require a scoped primary source; do not infer IIS version from older IIS 10 articles. |
| Hyper-V | Current Microsoft overview includes Windows Server 2025; hardware requirements page explicitly applies to Windows Server 2025 and lists prerequisites. [Overview](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview), [hardware requirements](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/host-hardware-requirements?pivots=windows). | Overview page notes AI-assisted authorship; use focused technical requirement pages for specific operational claims. No host lab was run. |
| PowerShell support | Microsoft lifecycle page reports PowerShell 7.6 LTS released 2026-03-18 with end of support 2028-11-14; PowerShell 7.5 support ends 2026-11-10; page also lists 7.7 preview. [Support lifecycle](https://learn.microsoft.com/en-us/powershell/scripting/install/powershell-support-lifecycle?view=powershell-7.5). The final direct-page recheck confirms current LTS 7.6.6 and stable 7.5.11; only the latest update of a release is supported. | Engine behaviour runner was observed in a PowerShell 7.4.2 Linux container; it is not an approved Windows production target assessment. Verify the module’s declared target PowerShell editions/versions against its manifest and Windows integration dependencies before proposing support changes. |
| Microsoft security baselines | Microsoft Intune “What’s new” lists a Windows 11 26H2 security baseline in the week of 2026-10-05 and says existing baseline profiles do not automatically update. [Intune updates](https://learn.microsoft.com/intune/intune-service/fundamentals/whats-new). | Baseline adoption is separate from release availability. Verify the exact current baseline package/settings before operational deployment. |
| Intune | Same Microsoft update page includes October 2026 changes, including 26H2 baseline availability. | Tenant rollouts/feature flags may vary. No tenant connected; tenant-side state is NOT_ASSESSED. |
| Entra | [Microsoft Entra what’s new](https://learn.microsoft.com/en-us/entra/fundamentals/whats-new) is the official update feed consulted during preflight. | No tenant-specific policy, identity risk, or portal availability was queried. Claims beyond the exact dated release items are NOT_ASSESSED. |
| Azure Arc | [Azure Arc Connected Machine agent release notes](https://learn.microsoft.com/en-us/azure/azure-arc/servers/agent-release-notes) is the official source checked. | The accessed release notes surface updates only through 2026-08; no October agent release was verified. Current latest agent version and fleet compatibility are NOT_ASSESSED. |

## Codex model-currentness

- Official OpenAI changelog records GPT-6.1 Terra released 2026-10-26; the existing Linux model review dated 2026-10-29 already records the release. [OpenAI changelog](https://developers.openai.com/api/docs/changelog). The official model page shows Terra’s intended visual reasoning/computer-use/writing fit and pricing, and the GPT-6 guide describes Luna as fastest/cost-effective for focused high-volume workloads. [Terra model page](https://developers.openai.com/api/docs/models/gpt-6.1-terra), [GPT-6 model guide](https://developers.openai.com/api/docs/guides/latest-model). (Synthesis.)
- The Codex runtime cache (local runtime model catalogue), read without exposing identity/account values, had `fetched_at=2026-10-29T07:33:19Z` and contained `gpt-6-luna`, `gpt-6.1-sol`, `gpt-6.1-terra`, `gpt-6-astra`, plus legacy/other entries. Cache supports `high` reasoning for Luna. Local cache proves that IDs were present in that cache at that time; it does not establish this session’s selected model or user-wide availability. (Local observation.)
- The user-level policy requests Luna/high for root/orchestration/review/execution and only allows Astra when Peter explicitly selects it. The Linux review dated 2026-10-29 reaches the same retain decision and says comparative quality/latency/retry-rate/total-cost benchmarking was not run. The current cache, fetched later on the same date, also lists Luna/high. This running root cannot establish that its model matches the requested pin; no running-session model switch is claimed. No model-policy change is indicated; comparative suitability remains NOT_ASSESSED. (Synthesis from user policy, local cache and Linux review.)

## Source-register status in engine checkout

The local register `engine/source-register.yaml` declares a 90-day review interval. It has 48 records; 38 have URLs, all 38 unique and reachable per `source-url-report.json`; 37 records are still `current-check-required`, and 10 have no accessed date. The URL verifier measures reachability, not semantic support. The prompt’s currentness gate requires claims, scope, source date, access/verification/review dates, freshness class and uncertainty; this register alone is incomplete for that evidence contract. (Synthesis from local register, currentness gate and URL check.)

## Review scope and security applicability

Next review: **2026-11-05**, or immediately before target execution, whichever
comes first. All rows are scoped observations, not approval to deploy the newest
release. Existing register entries retain their original verification status.
The runtime used for fixtures (PowerShell 7.4.2) is not a current supported patch;
it supplies reproducible language/state-machine proof only. Run the same checks
on supported Windows/PowerShell targets before release.

The [Microsoft Security Update Guide](https://msrc.microsoft.com/update-guide)
was accessed on 2026-10-29 but its dynamic advisory content was not retrievable
through this browser. Advisory enumeration, affected-build matching and patch
closure are **NOT_ASSESSED**. No target build, installed KB inventory or tenant
was supplied. A claim that all current cybersecurity issues are resolved would
therefore be unsupported. The operator must correlate the actual inventory with
the official advisory and release-health records, test the applicable fix in a
canary and retain verification plus rollback evidence. Do not disable SMB
signing, authentication or firewalls to make an incident disappear.

## Group Policy command contract

[Backup-GPO](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/backup-gpo?view=windowsserver2025-ps)
and [Get-GPOReport](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/get-gporeport?view=windowsserver2025-ps)
were checked on 2026-10-29. Capture the exact GPO identity, backup and report
before change. [Restore-GPO](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/restore-gpo?view=windowsserver2025-ps)
was available through the official indexed result after direct-page timeouts:
`-BackupId` identifies a particular backup rather than the GPO identifier;
restoration is to the original domain and requires the original GPO to exist.
Its `-WhatIf` preview does not prove effective policy or recovery on clients.
The worked plan keeps link reversal and client verification separate.
