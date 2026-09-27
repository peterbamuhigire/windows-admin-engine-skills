function Get-WseAdminActivityReport {
    [CmdletBinding()]
    param(
        [datetime]$FromUtc = [datetime]::UtcNow.AddDays(-30),
        [datetime]$ToUtc = [datetime]::UtcNow,
        [string[]]$RecordRoot,
        [string]$OutputPath
    )

    if (-not $RecordRoot -or $RecordRoot.Count -eq 0) {
        $configured = [Environment]::GetEnvironmentVariable('CHWEZI_ACTIVITY_ROOT')
        if (-not [string]::IsNullOrWhiteSpace($configured)) {
            $RecordRoot = @($configured)
        } else {
            $local = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
            $RecordRoot = @((Join-Path $local 'Chwezi\WindowsAdmin\activity'))
        }
    }
    $from = $FromUtc.ToUniversalTime()
    $to = $ToUtc.ToUniversalTime()
    if ($to -lt $from) { throw 'ToUtc must be at or after FromUtc.' }

    $events = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    $invalid = 0
    $required = @('schema_version','event_id','timestamp_utc','engine','activity_type','operation','target_scope','status','changed','summary','change_ref','evidence_refs','limitations')
    $validEngines = @('linux-skills','windows-admin-engine-skills')
    $validTypes = @('inventory','health_check','security','update','configuration','backup','recovery','incident','report','other')
    $validScopes = @('local','remote','fleet','unknown')
    $validStatuses = @('succeeded','no_change','partial','failed','blocked','not_assessed','pending_reboot')
    foreach ($rootPath in $RecordRoot) {
        if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) { continue }
        foreach ($file in Get-ChildItem -LiteralPath $rootPath -Filter 'activity-*.jsonl' -File -ErrorAction SilentlyContinue) {
            foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                try {
                    $item = $line | ConvertFrom-Json -ErrorAction Stop
                    if ($null -eq $item -or $item -isnot [System.Management.Automation.PSCustomObject]) { $invalid++; continue }
                    $propertyNames = @($item.PSObject.Properties | ForEach-Object { $_.Name })
                    if (@($required | Where-Object { $_ -notin $propertyNames }).Count -gt 0 -or @($propertyNames | Where-Object { $_ -notin $required }).Count -gt 0 -or
                        $item.schema_version -isnot [string] -or $item.timestamp_utc -isnot [string] -or
                        $item.schema_version -ne 'chwezi.system-admin-activity.v1' -or
                        $item.event_id -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$item.event_id) -or $item.event_id.Length -gt 100 -or
                        $item.engine -notin $validEngines -or $item.activity_type -notin $validTypes -or
                        $item.target_scope -notin $validScopes -or $item.status -notin $validStatuses -or
                        -not ($item.changed -is [bool]) -or
                        $item.operation -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$item.operation) -or $item.operation.Length -gt 120 -or
                        $item.summary -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$item.summary) -or $item.summary.Length -gt 500 -or
                        ($null -ne $item.change_ref -and ($item.change_ref -isnot [string] -or $item.change_ref.Length -gt 120)) -or
                        $item.evidence_refs -isnot [array] -or $item.evidence_refs.Count -gt 30 -or
                        $item.limitations -isnot [array] -or $item.limitations.Count -gt 30) { $invalid++; continue }
                    if (@($item.evidence_refs | Where-Object { $_ -isnot [string] -or $_.Length -gt 180 -or [string]::IsNullOrWhiteSpace($_) }).Count -gt 0 -or
                        @($item.limitations | Where-Object { $_ -isnot [string] -or $_.Length -gt 300 }).Count -gt 0) { $invalid++; continue }
                    $time = [datetime]::Parse([string]$item.timestamp_utc).ToUniversalTime()
                    if ($time -lt $from -or $time -gt $to) { continue }
                    if ($seen.ContainsKey([string]$item.event_id)) { continue }
                    $seen[[string]$item.event_id] = $true
                    $events.Add($item)
                } catch { $invalid++ }
            }
        }
    }
    $ordered = @($events | Sort-Object timestamp_utc, event_id)
    $counts = [ordered]@{}
    foreach ($event in $ordered) {
        $key = [string]$event.status
        if (-not $counts.Contains($key)) { $counts[$key] = 0 }
        $counts[$key]++
    }
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# System administration activity report')
    $lines.Add('')
    $lines.Add(('Period (UTC): {0:o} through {1:o}' -f $from, $to))
    $lines.Add('Engines: Windows admin engine and Linux skills when additional record roots are supplied')
    $lines.Add(('Recorded activities: {0}' -f $ordered.Count))
    $lines.Add(('Unreadable or malformed records: {0}' -f $invalid))
    $lines.Add('')
    $lines.Add('## Status summary')
    $lines.Add('')
    $lines.Add('| Status | Count |')
    $lines.Add('|---|---:|')
    if ($counts.Count -eq 0) { $lines.Add('| No recorded activity | 0 |') }
    foreach ($key in $counts.Keys) { $lines.Add(('| {0} | {1} |' -f $key, $counts[$key])) }
    $lines.Add('')
    $lines.Add('## Activity')
    $lines.Add('')
    $lines.Add('| UTC time | Engine | Type | Operation | Scope | Status | Changed | Summary | Change ref | Evidence refs | Limitations |')
    $lines.Add('|---|---|---|---|---|---|---:|---|---|---|---|')
    foreach ($event in $ordered) {
        $evidence = @($event.evidence_refs) -join ', '
        $limitations = @($event.limitations) -join '; '
        $cells = @($event.timestamp_utc, $event.engine, $event.activity_type, $event.operation, $event.target_scope, $event.status, [bool]$event.changed, $event.summary, $event.change_ref, $evidence, $limitations)
        $safeCells = @($cells | ForEach-Object { ([string]$_).Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ') })
        $lines.Add('| ' + ($safeCells -join ' | ') + ' |')
    }
    $lines.Add('')
    $lines.Add('This report summarizes recorded engine activity only. It does not prove that unrecorded host activity did not occur.')
    $markdown = $lines -join "`n"
    if ($OutputPath) {
        $fullPath = [System.IO.Path]::GetFullPath($OutputPath)
        $parent = Split-Path -Parent $fullPath
        if ($parent) { [System.IO.Directory]::CreateDirectory($parent) | Out-Null }
        [System.IO.File]::WriteAllText($fullPath, $markdown, (New-Object System.Text.UTF8Encoding($false)))
        return [pscustomobject]@{ Path=$fullPath; EventCount=$ordered.Count; InvalidRecordCount=$invalid; PeriodStartUtc=$from; PeriodEndUtc=$to }
    }
    return [pscustomobject]@{ Markdown=$markdown; EventCount=$ordered.Count; InvalidRecordCount=$invalid; PeriodStartUtc=$from; PeriodEndUtc=$to }
}
