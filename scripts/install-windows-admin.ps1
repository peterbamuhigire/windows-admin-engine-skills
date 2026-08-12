[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [ValidateSet('User')][string]$Scope = 'User',
    [switch]$ForceCollision,
    [switch]$SkipPathLengthCheck,
    [Parameter(DontShow=$true)][AllowNull()][string]$CurrentUserPathOverride,
    [Parameter(DontShow=$true)][AllowNull()][string]$PreviousEngineRootOverride
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\')
$commandsRoot = (Join-Path $repo 'commands').TrimEnd('\')
if (-not (Test-Path -LiteralPath (Join-Path $commandsRoot 'bin\wsa.cmd'))) {
    throw "Invalid command tree: $commandsRoot"
}

function Normalize-PathEntry([AllowNull()][string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    try {
        return [IO.Path]::GetFullPath($Value.Trim().Trim('"')).TrimEnd('\')
    } catch {
        return $Value.Trim().Trim('"').TrimEnd('\')
    }
}

function Test-PathUnderRoot([AllowNull()][string]$Value, [string[]]$Roots) {
    $normal = Normalize-PathEntry $Value
    if (-not $normal) { return $false }
    foreach ($rootValue in @($Roots)) {
        $root = Normalize-PathEntry $rootValue
        if (-not $root) { continue }
        if ($normal.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or
            $normal.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Get-PathReconciliation(
    [AllowNull()][string]$PathValue,
    [string[]]$DesiredDirectories,
    [string[]]$OwnedRoots
) {
    $desired = @($DesiredDirectories | ForEach-Object { Normalize-PathEntry $_ } | Where-Object { $_ } | Sort-Object -Unique)
    $desiredSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($item in $desired) { [void]$desiredSet.Add($item) }

    $currentForComparison = New-Object System.Collections.Generic.List[string]
    $currentSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $retained = New-Object System.Collections.Generic.List[string]
    $retainedSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $removed = New-Object System.Collections.Generic.List[string]
    $stale = New-Object System.Collections.Generic.List[string]

    foreach ($item in @($PathValue -split ';')) {
        $normal = Normalize-PathEntry $item
        if (-not $normal) { continue }
        $currentForComparison.Add($normal)
        [void]$currentSet.Add($normal)
        if (Test-PathUnderRoot $normal $OwnedRoots) {
            $removed.Add($normal)
            if (-not $desiredSet.Contains($normal)) { $stale.Add($normal) }
            continue
        }
        if ($retainedSet.Add($normal)) { $retained.Add($normal) }
    }

    $preservedDirectoryCount = $retained.Count

    $added = New-Object System.Collections.Generic.List[string]
    $reused = New-Object System.Collections.Generic.List[string]
    foreach ($item in $desired) {
        if ($currentSet.Contains($item)) { $reused.Add($item) } else { $added.Add($item) }
        if ($retainedSet.Add($item)) { $retained.Add($item) }
    }

    $proposed = $retained -join ';'
    $current = $currentForComparison -join ';'
    [pscustomobject]@{
        ProposedPath = $proposed
        Changed = -not $proposed.Equals($current, [StringComparison]::OrdinalIgnoreCase)
        RemovedDirectories = @($removed)
        StaleDirectories = @($stale)
        AddedDirectories = @($added)
        ReusedDirectories = @($reused)
        PreservedDirectoryCount = $preservedDirectoryCount
    }
}

if (($PSBoundParameters.ContainsKey('CurrentUserPathOverride') -or
     $PSBoundParameters.ContainsKey('PreviousEngineRootOverride')) -and -not $WhatIfPreference) {
    throw 'Path override parameters are test-only and require -WhatIf.'
}

$currentUserPath = if ($PSBoundParameters.ContainsKey('CurrentUserPathOverride')) {
    $CurrentUserPathOverride
} else {
    [Environment]::GetEnvironmentVariable('Path', 'User')
}
$previousEngineRoot = if ($PSBoundParameters.ContainsKey('PreviousEngineRootOverride')) {
    $PreviousEngineRootOverride
} else {
    [Environment]::GetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', 'User')
}

$ownedRoots = @($commandsRoot)
if (-not [string]::IsNullOrWhiteSpace($previousEngineRoot)) {
    $previousNormal = Normalize-PathEntry $previousEngineRoot
    if ([IO.Path]::IsPathRooted($previousNormal)) {
        $previousCommandsRoot = (Join-Path $previousNormal 'commands').TrimEnd('\')
        if (-not $previousCommandsRoot.Equals($commandsRoot, [StringComparison]::OrdinalIgnoreCase)) {
            $ownedRoots += $previousCommandsRoot
        }
    } else {
        Write-Warning 'Ignoring a non-absolute WINDOWS_ADMIN_ENGINE_ROOT value during cleanup.'
    }
}

# Every current command directory remains directly discoverable. Reconciliation
# removes obsolete directories first, so renamed or deleted commands do not
# leave dead PATH entries after an engine update.
$desired = @($commandsRoot)
foreach ($directory in @(Get-ChildItem -LiteralPath $commandsRoot -Directory -Recurse)) {
    $desired += $directory.FullName
}
$desired = @($desired | ForEach-Object { Normalize-PathEntry $_ } | Where-Object { $_ } | Sort-Object -Unique)

$collisions = New-Object System.Collections.Generic.List[object]
$nameSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($file in @(Get-ChildItem -LiteralPath $commandsRoot -Recurse -File)) {
    if ($file.Extension -in @('.cmd','.ps1') -and $file.BaseName -like 'wsa*') {
        [void]$nameSet.Add($file.BaseName)
    }
}
$commandNames = @($nameSet)
foreach ($name in $commandNames) {
    foreach ($existing in @(Get-Command $name -All -ErrorAction SilentlyContinue)) {
        $source = [string]$existing.Source
        if ($source -and -not (Test-PathUnderRoot $source $ownedRoots)) {
            $collisions.Add([pscustomobject]@{Command=$name;Existing=$source})
        }
    }
}
if ($collisions.Count -gt 0 -and -not $ForceCollision) {
    $collisions | Format-Table -AutoSize | Out-String | Write-Warning
    throw 'Command collisions found. Rename/remove the external command or rerun with -ForceCollision after review.'
}

$reconciliation = Get-PathReconciliation $currentUserPath $desired $ownedRoots
$newUserPath = $reconciliation.ProposedPath
if ($newUserPath.Length -gt 8191 -and -not $SkipPathLengthCheck) {
    throw "Proposed user PATH is $($newUserPath.Length) characters, above the 8,191-character cmd.exe compatibility gate. Use commands\bin\wsa.cmd through a single PATH entry or review -SkipPathLengthCheck."
}

$rootChanged = -not $repo.Equals((Normalize-PathEntry $previousEngineRoot), [StringComparison]::OrdinalIgnoreCase)
$changed = $reconciliation.Changed -or $rootChanged
$mode = if ([string]::IsNullOrWhiteSpace($previousEngineRoot)) { 'Install' } elseif ($changed) { 'Update' } else { 'NoChange' }
$plan = [pscustomobject]@{
    Scope = $Scope
    Mode = $mode
    Changed = $changed
    EngineRoot = $repo
    PreviousEngineRoot = $previousEngineRoot
    OwnedRoots = @($ownedRoots)
    RemovedDirectories = @($reconciliation.StaleDirectories)
    StaleDirectories = @($reconciliation.StaleDirectories)
    AddedDirectories = @($reconciliation.AddedDirectories)
    ReusedDirectories = @($reconciliation.ReusedDirectories)
    PreservedDirectoryCount = $reconciliation.PreservedDirectoryCount
    DirectoryCount = $desired.Count
    CommandCount = $commandNames.Count
    CollisionCount = $collisions.Count
    ProposedUserPathLength = $newUserPath.Length
}
$plan

if (-not $changed) {
    Write-Output 'Windows Administration command installation is already current.'
    return
}

$action = "Remove $($reconciliation.StaleDirectories.Count) stale engine PATH entries and register $($desired.Count) current command directories"
if ($PSCmdlet.ShouldProcess('User environment', $action)) {
    $oldUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $oldUserRoot = [Environment]::GetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', 'User')
    $oldProcessPath = $env:Path
    $oldProcessRoot = $env:WINDOWS_ADMIN_ENGINE_ROOT
    try {
        [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
        [Environment]::SetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', $repo, 'User')

        $processPlan = Get-PathReconciliation $env:Path $desired $ownedRoots
        $env:Path = $processPlan.ProposedPath
        $env:WINDOWS_ADMIN_ENGINE_ROOT = $repo

        $verifiedPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        $verifiedRoot = [Environment]::GetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', 'User')
        if (-not $newUserPath.Equals($verifiedPath, [StringComparison]::OrdinalIgnoreCase) -or
            -not $repo.Equals($verifiedRoot, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'User-environment verification did not match the proposed installation state.'
        }
        Write-Output "Installation reconciled: removed $($reconciliation.StaleDirectories.Count) stale entries and registered $($desired.Count) current directories. New terminal sessions inherit the updated PATH."
    } catch {
        $installFailure = $_.Exception.Message
        $rollbackErrors = New-Object System.Collections.Generic.List[string]
        try {
            [Environment]::SetEnvironmentVariable('Path', $oldUserPath, 'User')
            [Environment]::SetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT', $oldUserRoot, 'User')
        } catch {
            $rollbackErrors.Add("user environment: $($_.Exception.Message)")
        }
        try {
            $env:Path = $oldProcessPath
            if ($null -eq $oldProcessRoot) {
                Remove-Item Env:WINDOWS_ADMIN_ENGINE_ROOT -ErrorAction SilentlyContinue
            } else {
                $env:WINDOWS_ADMIN_ENGINE_ROOT = $oldProcessRoot
            }
        } catch {
            $rollbackErrors.Add("process environment: $($_.Exception.Message)")
        }
        if ($rollbackErrors.Count -gt 0) {
            throw "Installation reconciliation failed and rollback was incomplete ($($rollbackErrors -join '; ')). Original failure: $installFailure"
        }
        throw "Installation reconciliation failed; the prior environment was restored. $installFailure"
    }
}
