# Synthetic service-state test; no OS service or identity collector is used.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$repo = Split-Path -Parent $PSScriptRoot
. (Join-Path $repo 'powershell/WindowsSkills.Engine/Private/Resolve-WseLocalTarget.ps1')
. (Join-Path $repo 'powershell/WindowsSkills.Engine/Public/Invoke-WseServiceState.ps1')

# Substitute only the Windows identity/result adapter. Transition and target
# boundary functions above are the actual repository code under test.
function New-WseOperationResult {
    param($OperationId,$Command,$Target,$Status,$StartedAt,[bool]$Changed=$false,
          $Before,$After,$Verification,$RollbackArtifact,$Errors=@(),$Warnings=@())
    [pscustomobject]@{Status=$Status;Changed=$Changed;Before=$Before;After=$After;
        Verification=$Verification;RollbackArtifact=$RollbackArtifact;Errors=$Errors;Warnings=$Warnings}
}
function Get-Service {
    [CmdletBinding()]param([string]$Name)
    $script:lookups++
    if ($script:mode -eq 'lookup-failure') { throw 'fixture lookup failure' }
    [pscustomobject]@{Name=$Name;Status=$script:state}
}
function Stop-Service {
    [CmdletBinding()]param([string]$Name)
    $script:mutations++
    if ($script:mode -eq 'timeout') { return }
    $script:state='Stopped'
    if ($script:mode -in @('partial-failure','restore-failure')) { throw 'fixture partial mutation' }
}
function Start-Service {
    [CmdletBinding()]param([string]$Name)
    $script:mutations++
    if ($script:mode -eq 'restore-failure') { throw 'fixture recovery denied' }
    $script:state='Running'
}
function Assert-Fixture { param([bool]$Condition,[string]$Label)
    if (-not $Condition) { throw "FAIL: $Label" }
    $script:assertions++
}
function Reset-Fixture { param([string]$Mode='normal',[string]$State='Running')
    $script:mode=$Mode;$script:state=$State;$script:lookups=0;$script:mutations=0
}
$script:assertions=0
$parameters=@{Name='FixtureSvc';DesiredState='Stopped';ChangeAuthority='fixture-only';MaintenanceWindow='fixture-only';ComputerName='localhost';TimeoutSeconds=1;Confirm=$false}
Reset-Fixture
$r=Invoke-WseServiceState @parameters -WhatIf
Assert-Fixture ($r.Verification.State -eq 'PREVIEW' -and -not $r.Changed -and $script:mutations -eq 0) 'preview makes no mutation'
Reset-Fixture
$outside=$parameters.Clone();$outside.ComputerName='OUTSIDE-FIXTURE'
$r=Invoke-WseServiceState @outside -WhatIf
Assert-Fixture ($r.Status -eq 'Failed' -and -not $r.Changed -and $script:lookups -eq 0 -and $script:mutations -eq 0) 'remote target refused before lookup'
Reset-Fixture 'lookup-failure'
$r=Invoke-WseServiceState @parameters
Assert-Fixture ($r.Status -eq 'Failed' -and -not $r.Changed -and $script:mutations -eq 0) 'lookup error remains structured'
Reset-Fixture
$r=Invoke-WseServiceState @parameters
Assert-Fixture ($r.Status -eq 'Succeeded' -and $r.Changed -and $script:state -eq 'Stopped') 'bounded transition verified'
$r=Invoke-WseServiceState @parameters
Assert-Fixture ($r.Status -eq 'NoChange' -and -not $r.Changed -and $script:mutations -eq 1) 'repeat run makes no further change'
foreach($mode in @('partial-failure','timeout')) {
    Reset-Fixture $mode
    $r=Invoke-WseServiceState @parameters
    Assert-Fixture ($r.Status -eq 'Failed' -and $r.Changed -and $r.RollbackArtifact.State -eq 'VERIFIED' -and $r.After.Status -eq 'Running' -and $script:state -eq 'Running') "restored after $mode"
}
Reset-Fixture 'restore-failure'
$r=Invoke-WseServiceState @parameters
Assert-Fixture ($r.Status -eq 'Failed' -and $r.RollbackArtifact.State -eq 'FAILED' -and $null -eq $r.After) 'failed recovery is never reported verified'
Reset-Fixture 'normal' 'Paused'
$r=Invoke-WseServiceState @parameters
Assert-Fixture ($r.Status -eq 'Failed' -and -not $r.Changed -and $script:mutations -eq 0) 'non-recoverable original state refused'
Write-Output "service_state_fixture=PASS assertions=$script:assertions WindowsIntegration=NOT_ASSESSED"
