Describe 'B26 PowerShell semantics and partial-result fixtures' {
    BeforeAll {
        $repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $fixture = Get-Content (Join-Path $repo 'tests\fixtures\kaizen\powershell-semantics.json') -Raw | ConvertFrom-Json
    }

    It 'processes both elements of an array switch expression' {
        $actual = @(switch ('alpha','beta') { 'alpha' { 'A' } 'beta' { 'B' } })
        ($actual -join ',') | Should Be (($fixture.switch_array.expected_output) -join ',')
    }

    It 'keeps a partial cancellation result partial' {
        $results = @(
            [pscustomobject]@{Target='fictional-a';Status='Succeeded'}
            [pscustomobject]@{Target='fictional-b';Status='NotProcessed'}
            [pscustomobject]@{Target='fictional-c';Status='NotProcessed'}
        )
        ($results | Where-Object Status -eq 'NotProcessed').Count | Should Be 2
        $aggregate = if (($results | Where-Object Status -eq 'NotProcessed').Count -gt 0) { 'PartiallySucceeded' } else { 'Succeeded' }
        $aggregate | Should Be $fixture.cancellation.aggregate_status
        ($aggregate -eq 'Succeeded') | Should Be $fixture.cancellation.global_success
    }
}
