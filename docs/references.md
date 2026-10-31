# References

This page holds the citations that the repository [README](../README.md#references) summarises. The text was moved here from the README on 2026-10-31 without changing any entry.

Citations only. No book text or source conversion is stored in this repository (see `AGENTS.md`, "Never store book extractions"). The live register is `engine/source-register.yaml`.

## Books

- Allen, R. and Lowe-Norris, A. G. (2003) *Active Directory*, 2nd edn. O'Reilly Media. Historical AD concepts only.
- Berkouwer, S. (2022) *Active Directory Administration Cookbook*, 2nd edn. Packt. Every command verified before use.
- Dent, C. (2024) *Mastering PowerShell Scripting*, 5th edn. Packt.
- Hunter, L. E. and Allen, R. *Active Directory Cookbook*, 3rd edn. O'Reilly Media. Historical recipe taxonomy only.
- Jones, D. and Hicks, J. (2017) *The PowerShell Scripting and Toolmaking Book*.
- Krause, J. (2018) *Mastering Windows Group Policy*. Packt.
- Parlow, N. (2024) *PowerShell 7 Workshop*. Packt.
- Petty, J., Jones, D. and Hicks, J. (2022) *Learn PowerShell Scripting in a Month of Lunches*, 2nd edn, MEAP V04. Partial edition.
- Russinovich, M. and Margosis, A. (2016) *Troubleshooting with the Windows Sysinternals Tools*. Microsoft Press.
- Russinovich, M. and Solomon, D. (2005) *Microsoft Windows Internals*, 4th edn. Microsoft Press. Historical concepts only.

## Repositories

- PacktPublishing, *Active Directory Administration Cookbook, Second Edition* code repository: https://github.com/PacktPublishing/Active-Directory-Administration-Cookbook-Second-Edition. Used as a recipe inventory and a negative-engineering corpus; no script was imported or executed (`docs/research/source-synthesis.md`).
- Everything Claude Code (ECC): https://github.com/affaan-m/ECC. `windows-desktop-e2e-testing` is adapted from ECC's `skills/windows-desktop-e2e` (the pywinauto/UIA pattern set and a WPF worked example). `windows-portability-doctrine` is original synthesis that cites ECC's `install.sh`, the `continuous-learning-v2` skill and `TROUBLESHOOTING.md` as incident evidence. `docs/agent-runtime-safety.md` draws on ECC's shortform, longform and security guides.
- DietrichGebert/ponytail: https://github.com/DietrichGebert/ponytail (MIT). The `CLAUDE.md` → `@AGENTS.md` host-file bridge and single-source drift check (PT-01, PT-02, my-10-kaizen M10-02, commit `b1100c5`).
- pbakaus/impeccable: https://github.com/pbakaus/impeccable (Apache-2.0). The `PROJECT.md` (`project_schema: 1`) read rule (IM-11, M10-12, commit `243221f`) and the "Impeccable-derived AS overlay" quality gate in `AGENTS.md`.
- donvito/codex-astra-luna-orchestrator: https://github.com/donvito/codex-astra-luna-orchestrator. A concept reference for the `.codex/` model-policy helper, implemented independently.

## Standards and official sources

- JSON Schema draft 2020-12 (`engine/catalog.schema.json`, `engine/schemas/`): https://json-schema.org/draft/2020-12/schema
- Microsoft Security Compliance Toolkit (versioned security baselines): https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10
- Microsoft Learn, tier-1 entries in `engine/source-register.yaml` (accessed 2026-08-12 unless noted):
  - Windows Server management overview: https://learn.microsoft.com/en-us/windows-server/administration/overview
  - PowerShell documentation: https://learn.microsoft.com/en-us/powershell/
  - PowerShell remoting: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/running-remote-commands
  - Just Enough Administration: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/overview (and prerequisites)
  - Active Directory Domain Services overview: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview
  - Dcdiag: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dcdiag
  - AD replication error 1722: https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/replication-error-1722-rpc-server-unavailable
  - AD forest recovery guide: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-guide
  - Windows LAPS: https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview
  - Group Policy overview: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview
  - Windows Sysinternals: https://learn.microsoft.com/en-us/sysinternals/
  - Windows Admin Center: https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview
  - Get-WinEvent: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent
  - NetTCPIP module: https://learn.microsoft.com/en-us/powershell/module/nettcpip/
  - Windows Remote Management: https://learn.microsoft.com/en-us/windows/win32/winrm/portal
  - Microsoft Defender Antivirus: https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows
  - BitLocker: https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/
  - Windows Update: https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-overview
  - Windows Package Manager (WinGet): https://learn.microsoft.com/en-us/windows/package-manager/winget/
  - Windows Server storage: https://learn.microsoft.com/en-us/windows-server/storage/storage
  - SMB file sharing: https://learn.microsoft.com/en-us/windows-server/storage/file-server/file-server-smb-overview
  - Volume Shadow Copy Service: https://learn.microsoft.com/en-us/windows-server/storage/file-server/volume-shadow-copy-service
  - Windows Server Backup command reference: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-server-backup-command-reference
  - Windows services: https://learn.microsoft.com/en-us/windows/win32/services/services
  - IIS architecture: https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/introduction-to-iis-architecture
  - HTTP Server API (HTTP.sys): https://learn.microsoft.com/en-us/windows/win32/http/http-api-start-page
  - Hyper-V: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-overview
  - Windows containers: https://learn.microsoft.com/en-us/virtualization/windowscontainers/about/
  - Windows Subsystem for Linux: https://learn.microsoft.com/en-us/windows/wsl/about
  - Windows Performance Recorder: https://learn.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-recorder
  - Windows debugger: https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/
  - Azure Arc-enabled servers: https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview
  - Microsoft Intune: https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune
  - Microsoft Graph: https://learn.microsoft.com/en-us/graph/overview
  - Job Objects (accessed 2026-09-24): https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects
  - UI Automation (accessed 2026-09-24): https://learn.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32
  - Environment variables (accessed 2026-09-27): https://learn.microsoft.com/windows/win32/procthread/environment-variables
  - PowerShell DSC 3.0: https://learn.microsoft.com/en-us/powershell/dsc/overview
  - PSScriptAnalyzer: https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview
- CIS, DISA STIG and NIST mappings: named in `docs/plans/windows-engine/` as future crosswalks, "where legally licensed". They are not yet encoded.

## Websites and articles

- Pester: https://pester.dev/
- Accessibility Insights for Windows (Microsoft), named in `windows-desktop-e2e-testing`.
- pytest cache documentation: https://docs.pytest.org/en/stable/how-to/cache.html
- OpenAI image-generation and image-prompting guides, cited by `docs/ai-prompting/domain-prompt-compilation-contract.md`: https://developers.openai.com/api/docs/guides/image-generation and https://developers.openai.com/api/docs/guides/image-prompting
- Windows Administration Skills Engine repository: https://github.com/peterbamuhigire/windows-admin-engine-skills
