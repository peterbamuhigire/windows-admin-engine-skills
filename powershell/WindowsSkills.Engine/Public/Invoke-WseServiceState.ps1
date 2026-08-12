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
    $started=[datetime]::UtcNow;$id='service-'+[guid]::NewGuid().ToString('N');$warnings=New-Object System.Collections.Generic.List[string]
    try{$target=Resolve-WseLocalTarget $ComputerName;$svc=Get-Service -Name $Name -ErrorAction Stop;$before=[pscustomobject]@{Name=$svc.Name;Status=[string]$svc.Status};$changed=$false
        if([string]$svc.Status -eq $DesiredState){$result=New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'NoChange' -StartedAt $started -Before $before -After $before -Verification ([pscustomobject]@{State='VERIFIED';Expected=$DesiredState;Observed=[string]$svc.Status})}
        elseif(-not $PSCmdlet.ShouldProcess("$($target.Name)/$Name","Set service state to $DesiredState under authority $ChangeAuthority during $MaintenanceWindow")){$result=New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'NoChange' -StartedAt $started -Before $before -After $before -Verification ([pscustomobject]@{State='PREVIEW';Expected=$DesiredState;Observed=[string]$svc.Status}) -Warnings @('Preview or confirmation declined; no change was made.')}
        else{$changed=$true;if($DesiredState -eq 'Running'){Start-Service -Name $Name -ErrorAction Stop}else{Stop-Service -Name $Name -ErrorAction Stop};$deadline=(Get-Date).AddSeconds($TimeoutSeconds);do{Start-Sleep -Milliseconds 250;$svc=Get-Service -Name $Name -ErrorAction Stop}while([string]$svc.Status -ne $DesiredState -and (Get-Date) -lt $deadline)
            $after=[pscustomobject]@{Name=$svc.Name;Status=[string]$svc.Status};if([string]$svc.Status -ne $DesiredState){$warnings.Add('Verification failed; attempting rollback to '+$before.Status);if($before.Status -eq 'Running'){Start-Service -Name $Name -ErrorAction SilentlyContinue}else{Stop-Service -Name $Name -ErrorAction SilentlyContinue};throw "Service '$Name' did not reach '$DesiredState' before timeout."}
            $result=New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target $target -Status 'Succeeded' -StartedAt $started -Changed $changed -Before $before -After $after -Verification ([pscustomobject]@{State='VERIFIED';Expected=$DesiredState;Observed=[string]$svc.Status}) -RollbackArtifact ([pscustomobject]@{Type='ServiceState';Name=$Name;RestoreState=$before.Status}) -Warnings $warnings}
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Invoke-WseServiceState' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Changed $changed -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
