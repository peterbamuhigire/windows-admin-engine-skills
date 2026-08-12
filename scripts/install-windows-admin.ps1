[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [ValidateSet('User')][string]$Scope = 'User',
    [switch]$ForceCollision,
    [switch]$SkipPathLengthCheck
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\')
$commandsRoot = Join-Path $repo 'commands'
if (-not (Test-Path -LiteralPath (Join-Path $commandsRoot 'bin\wsa.cmd'))) { throw "Invalid command tree: $commandsRoot" }

function Normalize-PathEntry([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    try { return [IO.Path]::GetFullPath($Value.Trim().Trim('"')).TrimEnd('\') } catch { return $Value.Trim().Trim('"').TrimEnd('\') }
}

# The user requested the command root and every subdirectory on PATH. Keeping
# this explicit also makes newly added category/subcategory directories visible
# after a repair install.
$desired = @($commandsRoot)
foreach ($directory in @(Get-ChildItem -LiteralPath $commandsRoot -Directory -Recurse)) { $desired += $directory.FullName }
$desired = @($desired | ForEach-Object { Normalize-PathEntry $_ } | Where-Object { $_ } | Sort-Object -Unique)

$collisions = New-Object System.Collections.Generic.List[object]
$nameSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($file in @(Get-ChildItem -LiteralPath $commandsRoot -Recurse -File)) {
    if ($file.Extension -in @('.cmd','.ps1') -and $file.BaseName -like 'wsa*') { [void]$nameSet.Add($file.BaseName) }
}
$commandNames = @($nameSet)
foreach ($name in $commandNames) {
    foreach ($existing in @(Get-Command $name -All -ErrorAction SilentlyContinue)) {
        $source = [string]$existing.Source
        if ($source -and -not ([IO.Path]::GetFullPath($source).StartsWith($repo, [StringComparison]::OrdinalIgnoreCase))) {
            $collisions.Add([pscustomobject]@{Command=$name;Existing=$source})
        }
    }
}
if ($collisions.Count -gt 0 -and -not $ForceCollision) {
    $collisions | Format-Table -AutoSize | Out-String | Write-Warning
    throw 'Command collisions found. Rename/remove the external command or rerun with -ForceCollision after review.'
}

$currentUser = [Environment]::GetEnvironmentVariable('Path', 'User')
$entries = New-Object System.Collections.Generic.List[string]
$seen = @{}
foreach ($item in @($currentUser -split ';') + $desired) {
    $normal = Normalize-PathEntry $item
    if (-not $normal) { continue }
    $key = $normal.ToLowerInvariant()
    if (-not $seen.ContainsKey($key)) { $seen[$key]=$true; $entries.Add($normal) }
}
$newUserPath = $entries -join ';'
if ($newUserPath.Length -gt 8191 -and -not $SkipPathLengthCheck) {
    throw "Proposed user PATH is $($newUserPath.Length) characters, above the 8,191-character cmd.exe compatibility gate. Use commands\bin\wsa.cmd through a single PATH entry or review -SkipPathLengthCheck."
}

$plan = [pscustomobject]@{
    Scope = $Scope
    EngineRoot = $repo
    AddedDirectories = @($desired | Where-Object { $currentUser -split ';' -notcontains $_ })
    DirectoryCount = $desired.Count
    CommandCount = $commandNames.Count
    CollisionCount = $collisions.Count
    ProposedUserPathLength = $newUserPath.Length
}
$plan

if ($PSCmdlet.ShouldProcess('User environment', "Add $($desired.Count) Windows Administration command directories to PATH")) {
    [Environment]::SetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', $repo, 'User')
    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    $env:WINDOWS_ADMIN_ENGINE_ROOT = $repo
    $processEntries = New-Object System.Collections.Generic.List[string]
    $processSeen = @{}
    foreach($item in @($env:Path -split ';') + $desired){$normal=Normalize-PathEntry $item;if($normal){$key=$normal.ToLowerInvariant();if(-not $processSeen.ContainsKey($key)){$processSeen[$key]=$true;$processEntries.Add($normal)}}}
    $env:Path = $processEntries -join ';'
    Write-Output 'Installation complete for the user environment. New terminal sessions inherit the updated PATH.'
}
