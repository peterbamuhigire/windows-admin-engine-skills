Describe 'WindowsSkills.Engine administration activity records' {
    BeforeAll {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        Import-Module (Join-Path $moduleRoot 'WindowsSkills.Engine.psd1') -Force
    }

    BeforeEach {
        $script:priorActivityRoot = $env:CHWEZI_ACTIVITY_ROOT
        $env:CHWEZI_ACTIVITY_ROOT = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
    }

    AfterEach {
        if ($null -eq $script:priorActivityRoot) {
            Remove-Item Env:\CHWEZI_ACTIVITY_ROOT -ErrorAction SilentlyContinue
        } else {
            $env:CHWEZI_ACTIVITY_ROOT = $script:priorActivityRoot
        }
    }

    It 'records a concise event and renders encoded report fields' {
        $result = Add-WseAdminActivity -ActivityType security -Operation 'review local controls' -Status partial `
            -TargetScope local -Changed $false -Summary 'Reviewed <system> | evidence pending.' `
            -EvidenceReference 'case-activity-001' -Limitation 'Two controls were not assessed.'
        $result.SchemaVersion | Should -Be 'chwezi.system-admin-activity.v1'

        $report = Get-WseAdminActivityReport -FromUtc ([datetime]::UtcNow.AddMinutes(-2)) -ToUtc ([datetime]::UtcNow.AddMinutes(2))
        $report.EventCount | Should -Be 1
        $report.InvalidRecordCount | Should -Be 0
        $report.Markdown | Should -Match 'partial'
        $report.Markdown | Should -Match 'case-activity-001'
        $report.Markdown | Should -Match 'Two controls were not assessed\.'
        $report.Markdown | Should -Match ([regex]::Escape('&lt;system&gt; \| evidence pending.'))
    }

    It 'automatically records WindowsSkills.Engine operation results' {
        $operation = Get-WseSystemInventory
        (@('Succeeded','PartiallySucceeded') -contains $operation.Status) | Should -Be $true

        $report = Get-WseAdminActivityReport -FromUtc ([datetime]::UtcNow.AddMinutes(-2)) -ToUtc ([datetime]::UtcNow.AddMinutes(2))
        $report.EventCount | Should -Be 1
        $report.Markdown | Should -Match 'windows-admin-engine-skills'
        $report.Markdown | Should -Match 'inventory'
        $report.Markdown | Should -Match 'Recorded activities: 1'
    }

    It 'reads Linux schema records and deduplicates repeated input roots' {
        $root = $env:CHWEZI_ACTIVITY_ROOT
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        $record = [ordered]@{
            schema_version = 'chwezi.system-admin-activity.v1'
            event_id = 'linux-case-001'
            timestamp_utc = [datetime]::UtcNow.ToString('o')
            engine = 'linux-skills'
            activity_type = 'update'
            operation = 'security update review'
            target_scope = 'local'
            status = 'pending_reboot'
            changed = $true
            summary = 'Security packages installed; reboot pending.'
            change_ref = 'change-001'
            evidence_refs = @('case-activity-002')
            limitations = @('Linux host verification remains pending.')
        }
        $path = Join-Path $root ('activity-{0:yyyy-MM}.jsonl' -f [datetime]::UtcNow)
        [System.IO.File]::AppendAllText($path, (($record | ConvertTo-Json -Compress -Depth 5) + "`n"), (New-Object System.Text.UTF8Encoding($false)))

        $report = Get-WseAdminActivityReport -RecordRoot @($root, $root) -FromUtc ([datetime]::UtcNow.AddMinutes(-2)) -ToUtc ([datetime]::UtcNow.AddMinutes(2))
        $report.EventCount | Should -Be 1
        $report.Markdown | Should -Match 'linux-skills'
        $report.Markdown | Should -Match 'pending_reboot'
        $report.Markdown | Should -Match 'Linux host verification remains pending\.'
    }

    It 'counts malformed and schema-invalid imported rows and rejects secret-like manual text' {
        New-Item -ItemType Directory -Path $env:CHWEZI_ACTIVITY_ROOT -Force | Out-Null
        $path = Join-Path $env:CHWEZI_ACTIVITY_ROOT ('activity-{0:yyyy-MM}.jsonl' -f [datetime]::UtcNow)
        $common = [pscustomobject][ordered]@{
            schema_version = 'chwezi.system-admin-activity.v1'
            event_id = 'windows-invalid-base'
            timestamp_utc = [datetime]::UtcNow.ToString('o')
            engine = 'windows-admin-engine-skills'
            activity_type = 'inventory'
            operation = 'review inventory status'
            target_scope = 'local'
            status = 'succeeded'
            changed = $false
            summary = 'Read-only review completed.'
            change_ref = $null
            evidence_refs = @()
            limitations = @()
        }
        $absoluteReference = $common | Select-Object *
        $absoluteReference.event_id = 'windows-invalid-absolute-ref'
        $absoluteReference.evidence_refs = @('C:\private\host.txt')
        $secretLimitation = $common | Select-Object *
        $secretLimitation.event_id = 'windows-invalid-secret-limit'
        $secretLimitation.limitations = @('authorization: sample-value')
        $multilineLimitation = $common | Select-Object *
        $multilineLimitation.event_id = 'windows-invalid-multiline-limit'
        $multilineLimitation.limitations = @("line one`nline two")
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        $lines = @(
            '{malformed'
            ($absoluteReference | ConvertTo-Json -Compress -Depth 5)
            ($secretLimitation | ConvertTo-Json -Compress -Depth 5)
            ($multilineLimitation | ConvertTo-Json -Compress -Depth 5)
        )
        [System.IO.File]::WriteAllText($path, (($lines -join "`n") + "`n"), $utf8)

        $report = Get-WseAdminActivityReport -FromUtc ([datetime]::UtcNow.AddMinutes(-2)) -ToUtc ([datetime]::UtcNow.AddMinutes(2))
        $report.EventCount | Should -Be 0
        $report.InvalidRecordCount | Should -Be 4
        $report.Markdown.Contains('C:\private') | Should -Be $false
        $report.Markdown.Contains('sample-value') | Should -Be $false
        { Add-WseAdminActivity -ActivityType security -Operation 'review local controls' -Status failed `
            -TargetScope local -Changed $false -Summary 'token: sample-value' } | Should -Throw
    }
}
