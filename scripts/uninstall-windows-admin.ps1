[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param([ValidateSet('User')][string]$Scope = 'User')
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\')
$commandsRoot = (Join-Path $repo 'commands').TrimEnd('\')

function Is-EnginePath([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    try { $normal=[IO.Path]::GetFullPath($Value.Trim().Trim('"')).TrimEnd('\') } catch { return $false }
    return $normal.Equals($commandsRoot,[StringComparison]::OrdinalIgnoreCase) -or $normal.StartsWith($commandsRoot+'\',[StringComparison]::OrdinalIgnoreCase)
}

$current = [Environment]::GetEnvironmentVariable('Path','User')
$kept = @($current -split ';' | Where-Object { $_ -and -not (Is-EnginePath $_) })
$removed = @($current -split ';' | Where-Object { $_ -and (Is-EnginePath $_) })
[pscustomobject]@{Scope=$Scope;EngineRoot=$repo;RemovedDirectories=$removed;RemovedCount=$removed.Count}
if($PSCmdlet.ShouldProcess('User environment',"Remove $($removed.Count) Windows Administration command directories from PATH")){
    [Environment]::SetEnvironmentVariable('Path',($kept -join ';'),'User')
    if(([Environment]::GetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT','User')) -eq $repo){[Environment]::SetEnvironmentVariable('WINDOWS_ADMIN_ENGINE_ROOT',$null,'User')}
    $env:Path = (@($env:Path -split ';' | Where-Object { $_ -and -not (Is-EnginePath $_) }) -join ';')
    if($env:WINDOWS_ADMIN_ENGINE_ROOT -eq $repo){Remove-Item Env:WINDOWS_ADMIN_ENGINE_ROOT -ErrorAction SilentlyContinue}
    Write-Output 'Uninstall complete. No repository files were deleted.'
}
