function Get-WseSecuritySnapshot {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME, [string]$EvidenceRoot)
    $started=[datetime]::UtcNow;$id='security-'+[guid]::NewGuid().ToString('N');$warnings=New-Object System.Collections.Generic.List[string]
    try{$target=Resolve-WseLocalTarget $ComputerName;$data=[ordered]@{}
        if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){try{$mp=Get-MpComputerStatus -ErrorAction Stop;$data.Defender=$mp|Select-Object AMServiceEnabled,AntivirusEnabled,AntispywareEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated}catch{$warnings.Add('Defender status unavailable: '+$_.Exception.Message)}}else{$warnings.Add('Defender cmdlets unavailable.')}
        if(Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue){try{$data.BitLocker=@(Get-BitLockerVolume -ErrorAction Stop|Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionMethod,EncryptionPercentage)}catch{$warnings.Add('BitLocker status unavailable: '+$_.Exception.Message)}}else{$warnings.Add('BitLocker cmdlets unavailable.')}
        try{$data.SecureBoot=Confirm-SecureBootUEFI -ErrorAction Stop}catch{$warnings.Add('Secure Boot status NOT_ASSESSED: '+$_.Exception.Message)}
        if(Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue){$data.FirewallProfiles=@(Get-NetFirewallProfile|Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction)}
        $result=New-WseOperationResult -OperationId $id -Command 'Get-WseSecuritySnapshot' -Target $target -Status 'Succeeded' -StartedAt $started -After ([pscustomobject]$data) -Verification ([pscustomobject]@{State='OBSERVED';ComplianceClaim=$false;PolicyOwnership='NOT_ASSESSED'}) -Warnings $warnings
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Get-WseSecuritySnapshot' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
