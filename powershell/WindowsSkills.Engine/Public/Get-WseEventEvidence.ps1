function Get-WseEventEvidence {
    [CmdletBinding()]
    param([string]$ComputerName=$env:COMPUTERNAME,[string[]]$LogName=@('System','Application'),[ValidateRange(1,720)][int]$LookbackHours=24,[ValidateRange(1,5000)][int]$MaxEvents=250,[string]$EvidenceRoot)
    $started=[datetime]::UtcNow;$id='events-'+[guid]::NewGuid().ToString('N');$warnings=New-Object System.Collections.Generic.List[string]
    try{$target=Resolve-WseLocalTarget $ComputerName;$events=New-Object System.Collections.Generic.List[object];$since=(Get-Date).AddHours(-$LookbackHours)
        foreach($log in $LogName){try{Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=$since} -MaxEvents $MaxEvents -ErrorAction Stop|ForEach-Object{$events.Add(($_|Select-Object TimeCreated,LogName,Id,LevelDisplayName,ProviderName,MachineName,Message))}}catch{$warnings.Add("Log '$log' unavailable: "+$_.Exception.Message)}}
        $result=New-WseOperationResult -OperationId $id -Command 'Get-WseEventEvidence' -Target $target -Status 'Succeeded' -StartedAt $started -After @($events) -Verification ([pscustomobject]@{State='OBSERVED';LookbackHours=$LookbackHours;EventCount=$events.Count;Truncated=($events.Count -ge ($MaxEvents*$LogName.Count))}) -Warnings $warnings
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Get-WseEventEvidence' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
