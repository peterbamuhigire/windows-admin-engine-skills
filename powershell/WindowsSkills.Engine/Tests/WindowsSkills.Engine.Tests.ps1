Describe 'WindowsSkills.Engine contract' {
    BeforeAll {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        Import-Module (Join-Path $moduleRoot 'WindowsSkills.Engine.psd1') -Force
    }

    It 'imports required public functions' {
        (Test-WseEngine).Passed | Should -Be $true
    }

    It 'keeps manifest exports, Public files, loaded exports and the operator manual in step' {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        $manifestData = Import-PowerShellDataFile -Path (Join-Path $moduleRoot 'WindowsSkills.Engine.psd1')
        $declared = @($manifestData.FunctionsToExport | Sort-Object)
        $publicNames = @(Get-ChildItem -LiteralPath (Join-Path $moduleRoot 'Public') -Filter '*.ps1' -File | ForEach-Object { $_.BaseName } | Sort-Object)
        $loaded = @((Get-Module WindowsSkills.Engine).ExportedFunctions.Keys | Sort-Object)
        ($declared -join ',') | Should -Be ($publicNames -join ',')
        ($declared -join ',') | Should -Be ($loaded -join ',')
        $manualPath = Join-Path (Split-Path -Parent (Split-Path -Parent $moduleRoot)) 'docs\operations\commands-and-scripts-manual.md'
        $manual = Get-Content -LiteralPath $manualPath -Raw
        $undocumented = @($declared | Where-Object { -not $manual.Contains('`' + $_ + '`') })
        ($undocumented -join ',') | Should -Be ''
    }

    It 'collects local inventory without mutation' {
        $result = Get-WseSystemInventory
        $result.SchemaVersion | Should -Be '1.0'
        $result.Changed | Should -Be $false
        (@('Succeeded','PartiallySucceeded') -contains $result.Status) | Should -Be $true
        @($result.After.ExecutableResolution).Count | Should -Be 0
    }

    It 'reports a user PATH executable hidden from a stale process PATH without exposing PATH contents' {
        $command = Get-Command codex -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $command) { Set-ItResult -Skipped -Because 'Codex CLI is not installed on this host.'; return }
        $pathValues = @(
            [Environment]::GetEnvironmentVariable('PATH', 'Process'),
            [Environment]::GetEnvironmentVariable('PATH', 'User'),
            [Environment]::GetEnvironmentVariable('PATH', 'Machine')
        ) | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $originalPath = $env:PATH
        try {
            $env:PATH = Join-Path $env:SystemRoot 'System32'
            $result = Get-WseSystemInventory -ExecutableName codex
            $diagnostic = $result.After.ExecutableResolution | Where-Object Name -eq 'codex'
            $diagnostic.FoundInProcess | Should -Be $false
            $diagnostic.ResolvedDirectoryInUserPath | Should -Be $true
            ($diagnostic.PSObject.Properties.Name -contains 'ResolvedPath') | Should -Be $false
            ([DateTimeOffset]::Parse($result.After.ProcessContext.ObservedAt)).Offset | Should -Be ([TimeSpan]::Zero)
            ([DateTimeOffset]::Parse($result.After.PendingReboot.ObservedAt)).Offset | Should -Be ([TimeSpan]::Zero)
            $json = $result | ConvertTo-Json -Depth 20
            foreach ($pathValue in $pathValues) { $json.Contains($pathValue) | Should -Be $false }
        }
        finally { $env:PATH = $originalPath }
    }

    It 'finds Windows command shims when locating a command in persisted PATH entries' {
        $module = Get-Module WindowsSkills.Engine
        foreach ($extension in @('.exe', '.com', '.bat', '.cmd', '.ps1')) {
            $directory = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $directory ('codex' + $extension)) -Value 'fixture' -Encoding ASCII

            $resolved = & $module {
                param($commandName, $pathEntries)
                Find-WseCommandPathInPathEntries -Name $commandName -Directories $pathEntries
            } 'codex' @($directory)

            $resolved | Should -BeLike ('*' + [System.IO.Path]::DirectorySeparatorChar + 'codex' + $extension)
            (Test-Path -LiteralPath $resolved -PathType Leaf) | Should -Be $true
        }
    }

    It 'previews a service change without changing EventLog' {
        $before = (Get-Service EventLog).Status
        $result = Invoke-WseServiceState -Name EventLog -DesiredState Stopped -ChangeAuthority TEST -MaintenanceWindow TEST -WhatIf -Confirm:$false
        $result.Changed | Should -Be $false
        $result.Verification.State | Should -Be 'PREVIEW'
        (Get-Service EventLog).Status | Should -Be $before
    }
}
