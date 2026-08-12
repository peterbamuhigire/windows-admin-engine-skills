[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$files = @(Get-ChildItem -LiteralPath $repo -Recurse -File -Filter '*.ps1' | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
$findings = New-Object System.Collections.Generic.List[object]
foreach ($file in $files) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    foreach ($error in @($errors)) {
        $findings.Add([pscustomobject]@{File=$file.FullName.Substring($repo.Length+1);Line=$error.Extent.StartLineNumber;Message=$error.Message})
    }
}
if ($findings.Count -gt 0) { $findings | Format-Table -AutoSize | Out-String | Write-Error }
Write-Output "powershell_files=$($files.Count) syntax_findings=$($findings.Count)"
if ($findings.Count -gt 0) { exit 1 }
