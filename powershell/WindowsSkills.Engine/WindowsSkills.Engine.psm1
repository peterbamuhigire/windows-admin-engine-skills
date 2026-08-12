Set-StrictMode -Version 2.0

$privateFiles = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -File -ErrorAction Stop
$publicFiles = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -File -ErrorAction Stop

foreach ($file in @($privateFiles) + @($publicFiles)) {
    . $file.FullName
}

Export-ModuleMember -Function @(
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
