function Get-WseSystemInventory {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [string]$EvidenceRoot,
        [ValidatePattern('^[A-Za-z0-9_.-]+$')]
        [string[]]$ExecutableName = @()
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
        # Compare only membership of the resolved executable directory. Never
        # persist PATH values or resolved executable paths, which can contain
        # private locations or credentials. The executable check is opt-in.
        $processPath = @()
        $userPath = @()
        $machinePath = @()
        if ($ExecutableName.Count -gt 0) {
            $processPath = @(([Environment]::GetEnvironmentVariable('PATH', 'Process') -split ';') | Where-Object { $_ })
            $userPath = @(([Environment]::GetEnvironmentVariable('PATH', 'User') -split ';') | Where-Object { $_ })
            $machinePath = @(([Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';') | Where-Object { $_ })
        }
        $processContext = $null
        try {
            $currentProcess = Get-Process -Id $PID -ErrorAction Stop
            $parentRecord = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$PID" -ErrorAction Stop
            $parentProcess = if ($parentRecord.ParentProcessId) { Get-Process -Id ([int]$parentRecord.ParentProcessId) -ErrorAction SilentlyContinue }
            $processContext = [pscustomobject][ordered]@{
                ProcessId = $PID
                ProcessName = $currentProcess.ProcessName
                StartedAt = $currentProcess.StartTime.ToUniversalTime().ToString('o')
                ParentProcessId = [int]$parentRecord.ParentProcessId
                ParentProcessName = if ($parentProcess) { $parentProcess.ProcessName } else { $null }
                TerminalHostName = $Host.Name
                ObservedAt = [datetime]::UtcNow.ToString('o')
            }
        } catch { $warnings.Add('Process/terminal context unavailable: ' + $_.Exception.Message) }
        $executables = @(foreach ($name in $ExecutableName) {
            $resolved = Get-Command -Name $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
            $resolvedPath = if ($resolved) { [string]$resolved.Source } else { $null }
            $foundInProcess = [bool]$resolved
            # If process resolution fails, look for the exact command in the
            # persisted user/machine PATHs to identify an inheritance mismatch.
            if (-not $resolvedPath) {
                foreach ($entry in @($userPath) + @($machinePath)) {
                    if ($entry -and (Test-Path -LiteralPath (Join-Path $entry ($name + '.exe')) -PathType Leaf)) {
                        $resolvedPath = Join-Path $entry ($name + '.exe')
                        break
                    }
                }
            }
            $directory = if ($resolvedPath) { [System.IO.Path]::GetDirectoryName($resolvedPath) } else { $null }
            [pscustomobject][ordered]@{
                Name = $name
                FoundInProcess = $foundInProcess
                ResolvedDirectoryInProcessPath = [bool]($directory -and ($processPath | Where-Object { [string]::Equals($_.TrimEnd('\'), $directory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) }))
                ResolvedDirectoryInUserPath = [bool]($directory -and ($userPath | Where-Object { [string]::Equals($_.TrimEnd('\'), $directory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) }))
                ResolvedDirectoryInMachinePath = [bool]($directory -and ($machinePath | Where-Object { [string]::Equals($_.TrimEnd('\'), $directory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) }))
                ProcessPathSegmentCount = $processPath.Count
                UserPathSegmentCount = $userPath.Count
                MachinePathSegmentCount = $machinePath.Count
                CollectedAt = [datetime]::UtcNow.ToString('o')
            }
        })
        $pendingReboot = Get-WsePendingReboot
        $pendingReboot | Add-Member -NotePropertyName ObservedAt -NotePropertyValue ([datetime]::UtcNow.ToString('o'))
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
            ProcessContext = $processContext
            ExecutableResolution = $executables
            Elevated = Test-WseIsAdministrator
            PendingReboot = $pendingReboot
            Volumes = $volumes
            RolesAndFeatures = $roles
        }
        $result = New-WseOperationResult -OperationId $id -Command 'Get-WseSystemInventory' -Target $target -Status 'Succeeded' -StartedAt $started -Before $null -After $inventory -Verification ([pscustomobject]@{ State='OBSERVED'; CollectorCount=10 }) -Warnings $warnings
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
