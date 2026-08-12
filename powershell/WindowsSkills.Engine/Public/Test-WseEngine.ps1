function Test-WseEngine {
    [CmdletBinding()]
    param()
    $required=@('Get-WseSystemInventory','Test-WseSystemHealth','Get-WseNetworkSnapshot','Write-WseEvidencePack')
    $missing=@($required|Where-Object{-not (Get-Command $_ -ErrorAction SilentlyContinue)})
    [pscustomobject]@{SchemaVersion='1.0';ModuleVersion='0.1.0';PowerShell=$PSVersionTable.PSVersion.ToString();RequiredCommands=$required;MissingCommands=$missing;Passed=($missing.Count -eq 0);LiveLab='NOT_ASSESSED'}
}
