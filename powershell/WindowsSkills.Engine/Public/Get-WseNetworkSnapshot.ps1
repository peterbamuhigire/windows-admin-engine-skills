function Get-WseNetworkSnapshot {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME, [string]$EvidenceRoot)
    $started=[datetime]::UtcNow; $id='network-'+[guid]::NewGuid().ToString('N'); $warnings=New-Object System.Collections.Generic.List[string]
    try {
        $target=Resolve-WseLocalTarget $ComputerName
        $data=[ordered]@{}
        foreach($item in @(@('Adapters','Get-NetAdapter'),@('Addresses','Get-NetIPAddress'),@('Routes','Get-NetRoute'),@('DnsClientServers','Get-DnsClientServerAddress'),@('FirewallProfiles','Get-NetFirewallProfile'),@('TcpListeners','Get-NetTCPConnection'))){
            if(Get-Command $item[1] -ErrorAction SilentlyContinue){try{$value=& $item[1] -ErrorAction Stop;if($item[0] -eq 'TcpListeners'){$value=$value|Where-Object State -eq 'Listen'};$data[$item[0]]=@($value)}catch{$warnings.Add($item[1]+' unavailable: '+$_.Exception.Message)}}else{$warnings.Add($item[1]+' is not available on this platform.')}
        }
        $result=New-WseOperationResult -OperationId $id -Command 'Get-WseNetworkSnapshot' -Target $target -Status 'Succeeded' -StartedAt $started -After ([pscustomobject]$data) -Verification ([pscustomobject]@{State='OBSERVED';Mutated=$false}) -Warnings $warnings
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Get-WseNetworkSnapshot' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
