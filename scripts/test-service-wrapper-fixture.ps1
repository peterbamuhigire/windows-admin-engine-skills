# Isolated wrapper/dispatcher fixture; never imports the host's service module.
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
$temp=Join-Path ([IO.Path]::GetTempPath()) ('wsa-wrapper-'+[guid]::NewGuid().ToString('N'))
$exe=(Get-Process -Id $PID).Path
try {
    foreach($relative in @('commands/storage/services','commands/bin','commands/_lib','powershell/WindowsSkills.Engine')) {
        New-Item -ItemType Directory -Path (Join-Path $temp $relative) -Force | Out-Null
    }
    foreach($relative in @('commands/storage/services/wsa-service-state.ps1','commands/bin/wsa.ps1','commands/_lib/Invoke-WsaCommand.ps1')) {
        Copy-Item -LiteralPath (Join-Path $repo $relative) -Destination (Join-Path $temp $relative)
    }
    $module=Join-Path $temp 'powershell/WindowsSkills.Engine'
    foreach($source in @('Public/Invoke-WseServiceState.ps1','Private/Resolve-WseLocalTarget.ps1')) {
        Copy-Item -LiteralPath (Join-Path $repo ('powershell/WindowsSkills.Engine/'+$source)) -Destination $module
    }
    Set-Content -LiteralPath (Join-Path $module 'WindowsSkills.Engine.psd1') -Value "@{RootModule='Fixture.psm1';ModuleVersion='1.0.0';FunctionsToExport=@('Invoke-WseServiceState')}"
    @'
Set-StrictMode -Version 2.0
$script:lookups=0
$script:mutations=0
. (Join-Path $PSScriptRoot 'Resolve-WseLocalTarget.ps1')
. (Join-Path $PSScriptRoot 'Invoke-WseServiceState.ps1')
function Get-Service { [CmdletBinding()]param([string]$Name)
    $script:lookups++; [pscustomobject]@{Name=$Name;Status='Running'}
}
function Start-Service { [CmdletBinding()]param([string]$Name)
    $script:mutations++; throw 'Forbidden fixture mutation'
}
function Stop-Service { [CmdletBinding()]param([string]$Name)
    $script:mutations++; throw 'Forbidden fixture mutation'
}
function New-WseOperationResult {
    param($OperationId,$Command,$Target,$Status,$StartedAt,[bool]$Changed=$false,
          $Before,$After,$Verification,$RollbackArtifact,$Errors=@(),$Warnings=@())
    [pscustomobject]@{Status=$Status;Changed=$Changed;Before=$Before;After=$After;
        Verification=$Verification;Errors=$Errors;Lookups=$script:lookups;Mutations=$script:mutations}
}
'@ | Set-Content -LiteralPath (Join-Path $module 'Fixture.psm1')
    @'
param([string]$FixtureRoot,[string]$Case)
$ErrorActionPreference='Stop'
$env:COMPUTERNAME='FixtureLocal'
$arguments=@{Name='FixtureSvc';DesiredState='Stopped';ChangeAuthority='fixture authority with spaces';MaintenanceWindow='fixture window';ComputerName='localhost';WhatIf=$true;Confirm=$false}
if($Case -eq 'already-running'){$arguments.DesiredState='Running'}
if($Case -eq 'outside'){$arguments.ComputerName='OUTSIDE-FIXTURE'}
$result=& (Join-Path $FixtureRoot 'commands/storage/services/wsa-service-state.ps1') @arguments
$code=$LASTEXITCODE
$result | ConvertTo-Json -Depth 8 -Compress
exit $code
'@ | Set-Content -LiteralPath (Join-Path $temp 'run.ps1')
    $checks=0
    foreach($case in @('stop-preview','already-running','outside')) {
        $lines=& $exe -NoProfile -File (Join-Path $temp 'run.ps1') -FixtureRoot $temp -Case $case
        $code=$LASTEXITCODE
        $json=@($lines | Where-Object { $_ -like '{*' })[-1] | ConvertFrom-Json
        if($json.Changed -or $json.Mutations -ne 0){throw "$case mutated the fixture"}
        if($case -eq 'outside') {
            if($code -eq 0 -or $json.Status -ne 'Failed' -or $json.Lookups -ne 0){throw 'Out-of-scope wrapper refusal failed'}
        } else {
            if($code -ne 0 -or $json.Status -ne 'NoChange' -or $json.Before.Name -ne 'FixtureSvc'){throw "$case argument forwarding failed"}
            $expected=if($case -eq 'stop-preview'){'PREVIEW'}else{'VERIFIED'}
            if($json.Verification.State -ne $expected){throw "$case verification state differs"}
        }
        $checks++
    }
    Write-Output "service_wrapper_fixture=PASS invocations=$checks WindowsIntegration=NOT_ASSESSED"
} finally {
    if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Recurse -Force}
}
