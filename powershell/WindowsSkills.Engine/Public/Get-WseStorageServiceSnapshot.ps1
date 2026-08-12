function Get-WseStorageServiceSnapshot {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME,[string]$ServiceName,[string]$EvidenceRoot)
    $started=[datetime]::UtcNow;$id='storage-service-'+[guid]::NewGuid().ToString('N');$warnings=New-Object System.Collections.Generic.List[string]
    try{$target=Resolve-WseLocalTarget $ComputerName;$data=[ordered]@{}
        if(Get-Command Get-Disk -ErrorAction SilentlyContinue){$data.Disks=@(Get-Disk|Select-Object Number,FriendlyName,PartitionStyle,OperationalStatus,HealthStatus,Size,IsBoot,IsSystem)}else{$warnings.Add('Storage cmdlets unavailable.')}
        $data.Volumes=@(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'|Select-Object DeviceID,VolumeName,FileSystem,Size,FreeSpace)
        if($ServiceName){$data.Services=@(Get-CimInstance Win32_Service -Filter ("Name='"+$ServiceName.Replace("'","''")+"'")|Select-Object Name,DisplayName,State,StartMode,StartName,ExitCode)}else{$data.Services=@(Get-CimInstance Win32_Service|Select-Object Name,DisplayName,State,StartMode,StartName,ExitCode)}
        $result=New-WseOperationResult -OperationId $id -Command 'Get-WseStorageServiceSnapshot' -Target $target -Status 'Succeeded' -StartedAt $started -After ([pscustomobject]$data) -Verification ([pscustomobject]@{State='OBSERVED';EffectiveAccess='NOT_ASSESSED'}) -Warnings $warnings
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Get-WseStorageServiceSnapshot' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
