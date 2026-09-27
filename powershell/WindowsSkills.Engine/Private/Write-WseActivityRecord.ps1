function Write-WseActivityRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$OperationResult,
        [string]$ActivityRoot
    )

    if ([string]::IsNullOrWhiteSpace($ActivityRoot)) {
        $configured = [Environment]::GetEnvironmentVariable('CHWEZI_ACTIVITY_ROOT')
        if (-not [string]::IsNullOrWhiteSpace($configured)) {
            $ActivityRoot = $configured
        } else {
            $local = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
            if ([string]::IsNullOrWhiteSpace($local)) { throw 'LocalApplicationData is unavailable; set CHWEZI_ACTIVITY_ROOT or ActivityRoot explicitly.' }
            $ActivityRoot = Join-Path $local 'Chwezi\WindowsAdmin\activity'
        }
    }
    $root = [System.IO.Path]::GetFullPath($ActivityRoot)
    [System.IO.Directory]::CreateDirectory($root) | Out-Null

    $schemaProperty = $OperationResult.PSObject.Properties['schema_version']
    if ($schemaProperty -and [string]$schemaProperty.Value -eq 'chwezi.system-admin-activity.v1') {
        $record = $OperationResult
        $stamp = [datetime]::Parse([string]$record.timestamp_utc).ToUniversalTime()
    } else {
        $stamp = [datetime]::Parse([string]$OperationResult.FinishedAt).ToUniversalTime()
        $activityType = 'other'
        switch -Regex ([string]$OperationResult.Command) {
            'Inventory' { $activityType = 'inventory'; break }
            'Health' { $activityType = 'health_check'; break }
            'Security' { $activityType = 'security'; break }
            'EventEvidence' { $activityType = 'incident'; break }
            'Network|AdHealth' { $activityType = 'health_check'; break }
            'ServiceState' { $activityType = 'configuration'; break }
            'Storage' { $activityType = 'inventory'; break }
        }
        $status = switch ([string]$OperationResult.Status) {
            'NoChange' { 'no_change' }
            'Succeeded' { 'succeeded' }
            'Failed' { 'failed' }
            'PendingReboot' { 'pending_reboot' }
            'PartiallySucceeded' { 'partial' }
            'Aborted' { 'blocked' }
            default { 'not_assessed' }
        }
        $scope = if ([string]$OperationResult.Target.Kind -eq 'Local') { 'local' } elseif ([string]$OperationResult.Target.Kind) { 'remote' } else { 'unknown' }
        $record = [ordered]@{
            schema_version = 'chwezi.system-admin-activity.v1'
            event_id = [string]$OperationResult.OperationId
            timestamp_utc = $stamp.ToString('o')
            engine = 'windows-admin-engine-skills'
            activity_type = $activityType
            operation = ([string]$OperationResult.Command).Substring(0, [Math]::Min(120, ([string]$OperationResult.Command).Length))
            target_scope = $scope
            status = $status
            changed = [bool]$OperationResult.Changed
            summary = ('WindowsSkills.Engine operation completed with status {0}; changed={1}.' -f $status, [bool]$OperationResult.Changed)
            change_ref = $null
            evidence_refs = @()
            limitations = @()
        }
    }
    $path = Join-Path $root ('activity-{0:yyyy-MM}.jsonl' -f $stamp)
    $json = ($record | ConvertTo-Json -Compress -Depth 5) + "`n"
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $bytes = $encoding.GetBytes($json)
    $lastError = $null
    for ($attempt = 0; $attempt -lt 5; $attempt++) {
        $stream = $null
        try {
            $stream = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
            return $path
        } catch [System.IO.IOException] {
            $lastError = $_
            Start-Sleep -Milliseconds (25 * ($attempt + 1))
        } finally {
            if ($stream) { $stream.Dispose() }
        }
    }
    throw "Could not append the activity record after five attempts: $($lastError.Exception.Message)"
}
