function Test-WseSystemHealth {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [ValidateRange(1,99)][int]$MinimumFreePercent = 15,
        [ValidateRange(1,168)][int]$EventLookbackHours = 24,
        [string]$EvidenceRoot
    )

    $started = [datetime]::UtcNow
    $id = 'health-' + [guid]::NewGuid().ToString('N')
    $warnings = New-Object System.Collections.Generic.List[string]
    $findings = New-Object System.Collections.Generic.List[object]
    try {
        $target = Resolve-WseLocalTarget -ComputerName $ComputerName
        $reboot = Get-WsePendingReboot
        if ($reboot.Required) { $findings.Add([pscustomobject]@{Severity='Warning';Control='PendingReboot';Evidence=$reboot.Reasons;Action='Review workload and approved maintenance window.'}) }
        $disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)
        foreach ($disk in $disks) {
            if ($disk.Size -gt 0) {
                $free = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
                if ($free -lt $MinimumFreePercent) { $findings.Add([pscustomobject]@{Severity='Critical';Control='DiskCapacity';Evidence="$($disk.DeviceID) has $free percent free";Action='Route to windows-storage-files-services; do not delete automatically.'}) }
            }
        }
        $failedServices = @(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' -and $_.Name -notin @('sppsvc','MapsBroker','edgeupdate','gupdate') } | Select-Object Name,DisplayName,State,StartMode,ExitCode)
        foreach ($service in $failedServices) { $findings.Add([pscustomobject]@{Severity='Warning';Control='AutomaticService';Evidence=$service;Action='Confirm role and dependencies before restart.'}) }
        $events = @()
        try {
            $startTime = (Get-Date).AddHours(-$EventLookbackHours)
            $events = @(Get-WinEvent -FilterHashtable @{LogName='System'; Level=@(1,2); StartTime=$startTime} -MaxEvents 100 -ErrorAction Stop | Select-Object TimeCreated,Id,ProviderName,LevelDisplayName,Message)
        } catch { $warnings.Add('System event collection unavailable: ' + $_.Exception.Message) }
        $health = [pscustomobject]@{ Findings=@($findings); RecentCriticalOrErrorEvents=$events; PendingReboot=$reboot; AssessedAt=[datetime]::UtcNow.ToString('o') }
        $status = if (($findings | Where-Object Severity -eq 'Critical').Count -gt 0) { 'PartiallySucceeded' } else { 'Succeeded' }
        $result = New-WseOperationResult -OperationId $id -Command 'Test-WseSystemHealth' -Target $target -Status $status -StartedAt $started -RebootRequired $reboot.Required -After $health -Verification ([pscustomobject]@{State='OBSERVED';FindingCount=$findings.Count;Unassessed=@($warnings)}) -Warnings $warnings
    } catch {
        $result = New-WseOperationResult -OperationId $id -Command 'Test-WseSystemHealth' -Target @{Kind='Local';Name=$ComputerName;Fingerprint=$null} -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings
    }
    if ($EvidenceRoot) { $result.EvidencePath = Write-WseEvidencePack -OperationResult $result -EvidenceRoot $EvidenceRoot -Confirm:$false }
    $result
}
