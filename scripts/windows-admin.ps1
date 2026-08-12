[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments
)
$repo = Split-Path -Parent $PSScriptRoot
$env:PYTHONPATH = (Join-Path $repo 'python') + [IO.Path]::PathSeparator + $env:PYTHONPATH
& python -X utf8 -m windows_admin.cli --repo $repo @Arguments
exit $LASTEXITCODE
