function Find-WseCommandPathInPathEntries {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z0-9_.-]+$')]
        [string]$Name,

        [string[]]$Directories = @()
    )

    $extension = [System.IO.Path]::GetExtension($Name)
    $candidateNames = if ($extension) {
        @($Name)
    } else {
        # Windows CLI packages commonly expose command shims instead of an EXE.
        @('.exe', '.com', '.bat', '.cmd', '.ps1') | ForEach-Object { $Name + $_ }
    }

    foreach ($directory in $Directories) {
        if ([string]::IsNullOrWhiteSpace($directory)) { continue }
        foreach ($candidateName in $candidateNames) {
            $candidatePath = Join-Path $directory $candidateName
            if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
                return $candidatePath
            }
        }
    }

    return $null
}
