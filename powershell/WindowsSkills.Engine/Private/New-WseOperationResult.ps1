function New-WseOperationResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$OperationId,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][hashtable]$Target,
        [Parameter(Mandatory)][ValidateSet('NoChange','Succeeded','Failed','PendingReboot','PartiallySucceeded','Aborted')][string]$Status,
        [Parameter(Mandatory)][datetime]$StartedAt,
        [bool]$Changed = $false,
        [bool]$RebootRequired = $false,
        [bool]$DisconnectRisk = $false,
        $Before = $null,
        $After = $null,
        $Verification = $null,
        $RollbackArtifact = $null,
        [string]$EvidencePath = $null,
        [object[]]$Errors = @(),
        [object[]]$Warnings = @()
    )

    [pscustomobject][ordered]@{
        PSTypeName = 'WindowsSkills.OperationResult'
        SchemaVersion = '1.0'
        OperationId = $OperationId
        Command = $Command
        Target = [pscustomobject]$Target
        IdentityContext = [pscustomobject]@{
            User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
            Elevated = Test-WseIsAdministrator
            ProcessId = $PID
            PowerShellEdition = $PSVersionTable.PSEdition
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        }
        Status = $Status
        Changed = [bool]$Changed
        RebootRequired = [bool]$RebootRequired
        DisconnectRisk = [bool]$DisconnectRisk
        StartedAt = $StartedAt.ToUniversalTime().ToString('o')
        FinishedAt = [datetime]::UtcNow.ToString('o')
        Before = $Before
        After = $After
        Verification = $Verification
        RollbackArtifact = $RollbackArtifact
        EvidencePath = $EvidencePath
        Errors = @($Errors)
        Warnings = @($Warnings)
    }
}
