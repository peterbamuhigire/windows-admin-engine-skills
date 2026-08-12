function Get-WseAdHealth {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME, [string]$EvidenceRoot)
    $started=[datetime]::UtcNow;$id='ad-health-'+[guid]::NewGuid().ToString('N');$warnings=New-Object System.Collections.Generic.List[string]
    try{
        $target=Resolve-WseLocalTarget $ComputerName
        if(-not (Get-Module -ListAvailable ActiveDirectory)){throw 'The ActiveDirectory module is unavailable. Install approved RSAT tooling or run from a management host.'}
        Import-Module ActiveDirectory -ErrorAction Stop
        $domain=Get-ADDomain -ErrorAction Stop;$forest=Get-ADForest -ErrorAction Stop;$dcs=@(Get-ADDomainController -Filter * -ErrorAction Stop | Select-Object HostName,Site,IPv4Address,IsGlobalCatalog,OperationMasterRoles)
        $replication=[ordered]@{State='NOT_ASSESSED';ExitCode=$null;Output=@()}
        if(Get-Command repadmin.exe -ErrorAction SilentlyContinue){$out=@(& repadmin.exe /replsummary 2>&1);$replication.ExitCode=$LASTEXITCODE;$replication.Output=$out;$replication.State=if($LASTEXITCODE -eq 0){'OBSERVED'}else{'FAILED'}}else{$warnings.Add('repadmin.exe is unavailable; replication summary is NOT_ASSESSED.')}
        $data=[pscustomobject]@{Forest=$forest.Name;ForestMode=[string]$forest.ForestMode;Domains=@($forest.Domains);Domain=$domain.DNSRoot;DomainMode=[string]$domain.DomainMode;PDCEmulator=$domain.PDCEmulator;RIDMaster=$domain.RIDMaster;InfrastructureMaster=$domain.InfrastructureMaster;DomainControllers=$dcs;Replication=[pscustomobject]$replication}
        $status=if($replication.State -eq 'FAILED'){'PartiallySucceeded'}else{'Succeeded'}
        $result=New-WseOperationResult -OperationId $id -Command 'Get-WseAdHealth' -Target $target -Status $status -StartedAt $started -After $data -Verification ([pscustomobject]@{State='OBSERVED';Mutation=$false;Limit='DCDiag and per-partner replication require a domain lab.'}) -Warnings $warnings
    }catch{$result=New-WseOperationResult -OperationId $id -Command 'Get-WseAdHealth' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings}
    if($EvidenceRoot){$result.EvidencePath=Write-WseEvidencePack $result $EvidenceRoot -Confirm:$false};$result
}
