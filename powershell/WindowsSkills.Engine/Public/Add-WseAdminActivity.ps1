function Add-WseAdminActivity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('inventory','health_check','security','update','configuration','backup','recovery','incident','report','other')][string]$ActivityType,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Operation,
        [Parameter(Mandatory)][ValidateSet('succeeded','no_change','partial','failed','blocked','not_assessed','pending_reboot')][string]$Status,
        [Parameter(Mandatory)][ValidateSet('local','remote','fleet','unknown')][string]$TargetScope,
        [Parameter(Mandatory)][bool]$Changed,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Summary,
        [string]$ChangeReference,
        [string[]]$EvidenceReference = @(),
        [string[]]$Limitation = @(),
        [string]$ActivityRoot
    )
    if ($Summary.Length -gt 500 -or $Operation.Length -gt 120 -or $Operation.Contains("`n") -or $Operation.Contains("`r") -or $Summary.Contains("`n") -or $Summary.Contains("`r")) { throw 'Operation and summary exceed the activity schema limits.' }
    if (($Summary + ' ' + $Operation) -match '(?i)(password|passwd|token|secret|api[_-]?key|private[_-]?key|authorization)\s*[:=]') { throw 'Activity text resembles a secret-bearing field; remove sensitive values.' }
    if ($EvidenceReference.Count -gt 30 -or $Limitation.Count -gt 30) { throw 'The activity schema allows at most 30 evidence references and limitations.' }
    foreach ($reference in $EvidenceReference) {
        if ([string]::IsNullOrWhiteSpace($reference) -or $reference.Length -gt 180 -or $reference.Contains("`n") -or $reference.Contains("`r") -or [System.IO.Path]::IsPathRooted($reference) -or $reference -match '^[A-Za-z]:[/\\]' -or $reference.StartsWith('\\') -or $reference.Contains('..')) { throw 'Evidence references must be short relative identifiers without parent traversal.' }
    }
    if ($ChangeReference -and ($ChangeReference.Length -gt 120 -or $ChangeReference.Contains("`n") -or $ChangeReference.Contains("`r") -or $ChangeReference -match '(?i)(password|passwd|token|secret|api[_-]?key|private[_-]?key|authorization)\s*[:=]')) { throw 'Change reference is too long or resembles sensitive data.' }
    if (@($Limitation | Where-Object { $_.Contains("`n") -or $_.Contains("`r") -or $_ -match '(?i)(password|passwd|token|secret|api[_-]?key|private[_-]?key|authorization)\s*[:=]' }).Count -gt 0) { throw 'Limitation text must be single-line and must not contain secret-bearing fields.' }
    $record = [pscustomobject][ordered]@{
        schema_version = 'chwezi.system-admin-activity.v1'
        event_id = [guid]::NewGuid().ToString('D')
        timestamp_utc = [datetime]::UtcNow.ToString('o')
        engine = 'windows-admin-engine-skills'
        activity_type = $ActivityType
        operation = $Operation
        target_scope = $TargetScope
        status = $Status
        changed = $Changed
        summary = $Summary
        change_ref = if ($ChangeReference) { $ChangeReference.Substring(0, [Math]::Min(120, $ChangeReference.Length)) } else { $null }
        evidence_refs = @($EvidenceReference)
        limitations = @($Limitation | ForEach-Object { if ($_.Length -gt 300) { $_.Substring(0,300) } else { $_ } })
    }
    $path = Write-WseActivityRecord -OperationResult $record -ActivityRoot $ActivityRoot
    [pscustomobject]@{ EventId=$record.event_id; RecordedPath=$path; SchemaVersion=$record.schema_version }
}
