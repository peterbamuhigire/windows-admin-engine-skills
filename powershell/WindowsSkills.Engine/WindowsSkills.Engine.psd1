@{
    RootModule = 'WindowsSkills.Engine.psm1'
    ModuleVersion = '0.1.0'
    GUID = '8f32de6c-447a-47b2-9568-72921126e5ae'
    Author = 'Peter Bamuhigire'
    CompanyName = 'Chwezi Core Systems'
    Copyright = '(c) 2026 Peter Bamuhigire. MIT licensed.'
    Description = 'Safety, evidence, inventory, health, diagnostic, and controlled-change primitives for the Windows Administration Skills Engine.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-WseSystemInventory',
        'Test-WseSystemHealth',
        'Get-WseNetworkSnapshot',
        'Get-WseAdHealth',
        'Get-WseSecuritySnapshot',
        'Get-WseStorageServiceSnapshot',
        'Get-WseEventEvidence',
        'Invoke-WseServiceState',
        'Write-WseEvidencePack',
        'Test-WseEngine'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Windows','Administration','Evidence','Safety')
            ProjectUri = 'https://github.com/peterbamuhigire/windows-admin-engine-skills'
            LicenseUri = 'https://opensource.org/license/mit'
        }
    }
}
