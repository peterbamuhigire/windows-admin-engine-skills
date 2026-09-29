[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $repo 'powershell\WindowsSkills.Engine\WindowsSkills.Engine.psd1'
Import-Module $manifest -Force
$doctor = Test-WseEngine
if (-not $doctor.Passed) { throw "Module doctor failed: $($doctor.MissingCommands -join ', ')" }
$inventory = Get-WseSystemInventory
if ($inventory.Status -notin @('Succeeded','PartiallySucceeded')) { throw "Inventory smoke test failed: $($inventory.Errors -join '; ')" }
if ($inventory.Changed) { throw 'Read-only inventory reported a change.' }
$preview = Invoke-WseServiceState -Name 'EventLog' -DesiredState 'Stopped' -ChangeAuthority 'static-test' -MaintenanceWindow 'none' -WhatIf -Confirm:$false
if ($preview.Changed) { throw 'WhatIf service test reported a change.' }
# The Pester suites use Pester 5 syntax (Should -Be); GitHub windows runners ship Pester 5.
# Fail loudly on an older Pester rather than skipping, so a local pass means the CI suites ran.
$pester = Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1
if (-not $pester -or $pester.Version.Major -lt 5) {
    throw "Pester 5 or later is required (found: $(if ($pester) { $pester.Version } else { 'none' })). Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser -SkipPublisherCheck"
}
Import-Module Pester -MinimumVersion 5.0 -Force
& {
    $pesterPaths = @(
        (Join-Path $repo 'powershell\WindowsSkills.Engine\Tests\WindowsSkills.Engine.Tests.ps1')
        (Join-Path $repo 'powershell\WindowsSkills.Engine\Tests\AdminActivity.Tests.ps1')
        (Join-Path $repo 'tests\powershell\Install-WindowsAdmin.Tests.ps1')
        (Join-Path $repo 'tests\powershell\Kaizen-Semantics.Tests.ps1')
    )
    foreach ($pesterPath in $pesterPaths) {
        $pesterResult = Invoke-Pester -Path $pesterPath -PassThru
        if ($pesterResult.FailedCount -gt 0) { throw "Pester failed in $pesterPath`: $($pesterResult.FailedCount) tests" }
    }
}
Write-Output "powershell_smoke=PASS inventory=$($inventory.Status) preview=$($preview.Verification.State)"
