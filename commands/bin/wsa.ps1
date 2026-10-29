[CmdletBinding()]
param([Parameter(Mandatory,Position=0)][string]$Command,[Parameter(ValueFromRemainingArguments=$true)][object[]]$RemainingArguments,[hashtable]$NamedArguments=@{})
$root=$PSScriptRoot;while($root -and -not (Test-Path (Join-Path $root 'commands\_lib\Invoke-WsaCommand.ps1'))){$next=Split-Path -Parent $root;if($next -eq $root){break};$root=$next}
$results = & (Join-Path $root 'commands\_lib\Invoke-WsaCommand.ps1') -Command $Command -NamedArguments $NamedArguments -RemainingArguments $RemainingArguments
$invocationSucceeded = $?
$results
$failedResult = @($results | Where-Object { $_ -and $_.PSObject.Properties['Status'] -and $_.Status -eq 'Failed' }).Count -gt 0
if (-not $invocationSucceeded -or $failedResult) { $global:LASTEXITCODE = 1; exit 1 }
$global:LASTEXITCODE = 0
exit 0
