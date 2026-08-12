[CmdletBinding()]
param([Parameter(Mandatory,Position=0)][string]$Command,[Parameter(ValueFromRemainingArguments=$true)][object[]]$RemainingArguments)
$root=$PSScriptRoot;while($root -and -not (Test-Path (Join-Path $root 'commands\_lib\Invoke-WsaCommand.ps1'))){$next=Split-Path -Parent $root;if($next -eq $root){break};$root=$next}
& (Join-Path $root 'commands\_lib\Invoke-WsaCommand.ps1') $Command @RemainingArguments
if (-not $?) { $global:LASTEXITCODE = 1; exit 1 }
$global:LASTEXITCODE = 0
exit 0
