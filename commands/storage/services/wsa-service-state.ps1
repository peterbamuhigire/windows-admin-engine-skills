[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Name,
    [Parameter(Mandatory)][ValidateSet('Running','Stopped')][string]$DesiredState,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$ChangeAuthority,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$MaintenanceWindow,
    [string]$ComputerName=$env:COMPUTERNAME,
    [ValidateRange(1,300)][int]$TimeoutSeconds=30,
    [string]$EvidenceRoot
)
& (Join-Path $PSScriptRoot '../../bin/wsa.ps1') -Command service-state -NamedArguments $PSBoundParameters
exit $LASTEXITCODE
