Describe 'Windows Administration installer reconciliation' {
    BeforeAll {
        $repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $installer = Join-Path $repo 'scripts\install-windows-admin.ps1'
        $commands = Join-Path $repo 'commands'
    }

    It 'replaces stale numbered command paths in one previewed update' {
        $fixture = @(
            'C:\UnrelatedTools'
            (Join-Path $commands '00-engine')
            (Join-Path $commands '01-inventory\system')
            (Join-Path $commands 'bin')
        ) -join ';'

        $output = & $installer -WhatIf -ForceCollision -CurrentUserPathOverride $fixture -PreviousEngineRootOverride $repo
        $plan = @($output | Where-Object { $_.PSObject.Properties.Name -contains 'ProposedUserPathLength' })[0]

        $plan.Mode | Should Be 'Update'
        $plan.Changed | Should Be $true
        $plan.StaleDirectories.Count | Should Be 2
        $plan.PreservedDirectoryCount | Should Be 1
        ($plan.StaleDirectories -contains (Join-Path $commands '00-engine')) | Should Be $true
        ($plan.StaleDirectories -contains (Join-Path $commands '01-inventory\system')) | Should Be $true
        ($plan.AddedDirectories -contains (Join-Path $commands 'engine\catalog')) | Should Be $true
        ($plan.AddedDirectories -contains (Join-Path $commands 'inventory\system')) | Should Be $true
    }

    It 'is idempotent when the proposed path is checked again' {
        $desired = @($commands)
        $desired += @(Get-ChildItem -LiteralPath $commands -Directory -Recurse | Select-Object -ExpandProperty FullName)
        $installedPath = @('C:\UnrelatedTools') + @($desired | Sort-Object -Unique)
        $second = & $installer -WhatIf -ForceCollision -CurrentUserPathOverride ($installedPath -join ';') -PreviousEngineRootOverride $repo
        $secondPlan = @($second | Where-Object { $_.PSObject.Properties.Name -contains 'ProposedUserPathLength' })[0]

        $secondPlan.Mode | Should Be 'NoChange'
        $secondPlan.Changed | Should Be $false
        $secondPlan.StaleDirectories.Count | Should Be 0
        $secondPlan.AddedDirectories.Count | Should Be 0
    }

    It 'removes command paths from a previously registered checkout' {
        $fixture = 'C:\UnrelatedTools;D:\OldWindowsEngine\commands\bin;D:\OldWindowsEngine\commands\inventory\system'
        $output = & $installer -WhatIf -ForceCollision -CurrentUserPathOverride $fixture -PreviousEngineRootOverride 'D:\OldWindowsEngine'
        $plan = @($output | Where-Object { $_.PSObject.Properties.Name -contains 'ProposedUserPathLength' })[0]

        $plan.StaleDirectories.Count | Should Be 2
        $plan.PreservedDirectoryCount | Should Be 1
        ($plan.StaleDirectories -contains 'D:\OldWindowsEngine\commands\bin') | Should Be $true
        ($plan.StaleDirectories -contains 'D:\OldWindowsEngine\commands\inventory\system') | Should Be $true
        $plan.EngineRoot | Should Be $repo
    }

    It 'refuses path overrides outside WhatIf mode' {
        { & $installer -CurrentUserPathOverride 'C:\Test' } | Should Throw
    }
}
