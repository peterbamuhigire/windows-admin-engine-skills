function Get-WseSystemInventory {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [string]$EvidenceRoot
    )

    $started = [datetime]::UtcNow
    $id = 'inventory-' + [guid]::NewGuid().ToString('N')
    $warnings = New-Object System.Collections.Generic.List[string]
    try {
        $target = Resolve-WseLocalTarget -ComputerName $ComputerName
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $computer = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue
        $volumes = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{ DeviceId=$_.DeviceID; FileSystem=$_.FileSystem; SizeBytes=[int64]$_.Size; FreeBytes=[int64]$_.FreeSpace }
        })
        $roles = @()
        if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
            $roles = @(Get-WindowsFeature -ErrorAction SilentlyContinue | Where-Object Installed | Select-Object Name,DisplayName)
        }
        $inventory = [pscustomobject][ordered]@{
            CollectedAt = [datetime]::UtcNow.ToString('o')
            ComputerName = $env:COMPUTERNAME
            Domain = $computer.Domain
            DomainRole = $computer.DomainRole
            Manufacturer = $computer.Manufacturer
            Model = $computer.Model
            TotalPhysicalMemoryBytes = [int64]$computer.TotalPhysicalMemory
            OS = [pscustomobject]@{ Caption=$os.Caption; Version=$os.Version; BuildNumber=$os.BuildNumber; Architecture=$os.OSArchitecture; InstallDate=$os.InstallDate; LastBootUpTime=$os.LastBootUpTime }
            BIOS = if ($bios) { [pscustomobject]@{ Manufacturer=$bios.Manufacturer; SMBIOSBIOSVersion=$bios.SMBIOSBIOSVersion } } else { $null }
            PowerShell = [pscustomobject]@{ Edition=$PSVersionTable.PSEdition; Version=$PSVersionTable.PSVersion.ToString(); LanguageMode=$ExecutionContext.SessionState.LanguageMode.ToString() }
            Elevated = Test-WseIsAdministrator
            PendingReboot = Get-WsePendingReboot
            Volumes = $volumes
            RolesAndFeatures = $roles
        }
        $result = New-WseOperationResult -OperationId $id -Command 'Get-WseSystemInventory' -Target $target -Status 'Succeeded' -StartedAt $started -Before $null -After $inventory -Verification ([pscustomobject]@{ State='OBSERVED'; CollectorCount=8 }) -Warnings $warnings
    } catch {
        $fallbackTarget = @{Kind='Local';Name=$ComputerName;Fingerprint=$null}
        $result = New-WseOperationResult -OperationId $id -Command 'Get-WseSystemInventory' -Target $fallbackTarget -Status 'Failed' -StartedAt $started -Errors @($_.Exception.Message) -Warnings $warnings
    }
    if ($EvidenceRoot) {
        $path = Write-WseEvidencePack -OperationResult $result -EvidenceRoot $EvidenceRoot -Confirm:$false
        $result.EvidencePath = $path
    }
    $result
}
