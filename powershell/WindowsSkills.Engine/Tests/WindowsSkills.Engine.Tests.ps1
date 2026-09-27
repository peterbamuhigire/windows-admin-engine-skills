Describe 'WindowsSkills.Engine contract' {
    BeforeAll {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        Import-Module (Join-Path $moduleRoot 'WindowsSkills.Engine.psd1') -Force
    }

    It 'imports required public functions' {
        (Test-WseEngine).Passed | Should Be $true
    }

    It 'collects local inventory without mutation' {
        $result = Get-WseSystemInventory
        $result.SchemaVersion | Should Be '1.0'
        $result.Changed | Should Be $false
        (@('Succeeded','PartiallySucceeded') -contains $result.Status) | Should Be $true
        @($result.After.ExecutableResolution).Count | Should Be 0
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
            $diagnostic.FoundInProcess | Should Be $false
            $diagnostic.ResolvedDirectoryInUserPath | Should Be $true
            ($diagnostic.PSObject.Properties.Name -contains 'ResolvedPath') | Should Be $false
            ([DateTimeOffset]::Parse($result.After.ProcessContext.ObservedAt)).Offset | Should Be ([TimeSpan]::Zero)
            ([DateTimeOffset]::Parse($result.After.PendingReboot.ObservedAt)).Offset | Should Be ([TimeSpan]::Zero)
            $json = $result | ConvertTo-Json -Depth 20
            foreach ($pathValue in $pathValues) { $json.Contains($pathValue) | Should Be $false }
        }
        finally { $env:PATH = $originalPath }
    }

    It 'previews a service change without changing EventLog' {
        $before = (Get-Service EventLog).Status
        $result = Invoke-WseServiceState -Name EventLog -DesiredState Stopped -ChangeAuthority TEST -MaintenanceWindow TEST -WhatIf -Confirm:$false
        $result.Changed | Should Be $false
        $result.Verification.State | Should Be 'PREVIEW'
        (Get-Service EventLog).Status | Should Be $before
    }
}
