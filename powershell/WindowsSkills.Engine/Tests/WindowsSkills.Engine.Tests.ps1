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
    }

    It 'previews a service change without changing EventLog' {
        $before = (Get-Service EventLog).Status
        $result = Invoke-WseServiceState -Name EventLog -DesiredState Stopped -ChangeAuthority TEST -MaintenanceWindow TEST -WhatIf -Confirm:$false
        $result.Changed | Should Be $false
        $result.Verification.State | Should Be 'PREVIEW'
        (Get-Service EventLog).Status | Should Be $before
    }
}
