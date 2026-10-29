function Invoke-WseServiceState {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Name,
        [Parameter(Mandatory)][ValidateSet('Running','Stopped')][string]$DesiredState,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$ChangeAuthority,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$MaintenanceWindow,
        [string]$ComputerName=$env:COMPUTERNAME,
        [ValidateRange(1,300)][int]$TimeoutSeconds=30,
        [string]$EvidenceRoot
    )
    $started = [datetime]::UtcNow
    $id = 'service-' + [guid]::NewGuid().ToString('N')
    $warnings = New-Object System.Collections.Generic.List[string]
    $changed = $false
    $before = $null
    $after = $null
    $rollback = $null
    $target = @{Kind='Local'; Name=$ComputerName; Fingerprint=$null}

    # State polling after each service cmdlet returns is bounded; the cmdlet call itself
    # remains synchronous and is not interrupted by TimeoutSeconds.
    function Wait-WseServiceState {
        param([string]$Expected)
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        do {
            $observed = Get-Service -Name $Name -ErrorAction Stop
            if ([string]$observed.Status -eq $Expected) { return $observed }
            if ($watch.Elapsed.TotalSeconds -ge $TimeoutSeconds) { break }
            Start-Sleep -Milliseconds 250
        } while ($true)
        throw "Service '$Name' did not reach '$Expected' before timeout."
    }

    try {
        $target = Resolve-WseLocalTarget -ComputerName $ComputerName
        $svc = Get-Service -Name $Name -ErrorAction Stop
        $before = [pscustomobject]@{Name=$svc.Name; Status=[string]$svc.Status}
        $after = $before
        if ($before.Status -eq $DesiredState) {
            $result = New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'NoChange' -StartedAt $started -Before $before -After $after -Verification ([pscustomobject]@{State='VERIFIED'; Expected=$DesiredState; Observed=$before.Status})
        } elseif (-not $PSCmdlet.ShouldProcess("$($target.Name)/$Name", "Set service state to $DesiredState under authority $ChangeAuthority during $MaintenanceWindow")) {
            $result = New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'NoChange' -StartedAt $started -Before $before -After $after -Verification ([pscustomobject]@{State='PREVIEW'; Expected=$DesiredState; Observed=$before.Status}) -Warnings @('Preview or confirmation declined; no change was made.')
        } else {
            # Pending/paused states have no supported inverse in this operation.
            if ($before.Status -notin @('Running','Stopped')) {
                throw "Original service state '$($before.Status)' has no supported recovery transition."
            }
            $rollback = [pscustomobject]@{Type='ServiceState'; Name=$Name; RestoreState=$before.Status; State='NOT_ATTEMPTED'}
            # A throwing service command may already have changed the target.
            $changed = $true
            if ($DesiredState -eq 'Running') { Start-Service -Name $Name -ErrorAction Stop }
            else { Stop-Service -Name $Name -ErrorAction Stop }
            $svc = Wait-WseServiceState -Expected $DesiredState
            $after = [pscustomobject]@{Name=$svc.Name; Status=[string]$svc.Status}
            $result = New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'Succeeded' -StartedAt $started -Changed $changed -Before $before -After $after -Verification ([pscustomobject]@{State='VERIFIED'; Expected=$DesiredState; Observed=$after.Status}) -RollbackArtifact $rollback
        }
    } catch {
        $failure = $_.Exception.Message
        if ($changed -and $null -ne $before) {
            $warnings.Add('Change failed; restoring and verifying the original service state.')
            try {
                if ($before.Status -eq 'Running') { Start-Service -Name $Name -ErrorAction Stop }
                else { Stop-Service -Name $Name -ErrorAction Stop }
                $restored = Wait-WseServiceState -Expected $before.Status
                $after = [pscustomobject]@{Name=$restored.Name; Status=[string]$restored.Status}
                $rollback.State = 'VERIFIED'
            } catch {
                $rollback.State = 'FAILED'
                $after = $null
                $warnings.Add('Recovery failed; stop further changes and escalate: ' + $_.Exception.Message)
            }
        }
        $recovery = if ($rollback) { $rollback.State } else { 'NOT_REQUIRED' }
        $result = New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'Failed' -StartedAt $started -Changed $changed -Before $before -After $after -Verification ([pscustomobject]@{State='FAILED'; Recovery=$recovery}) -RollbackArtifact $rollback -Errors @($failure) -Warnings $warnings
    }
    if ($EvidenceRoot) { $result.EvidencePath = Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false }
    $result
}
