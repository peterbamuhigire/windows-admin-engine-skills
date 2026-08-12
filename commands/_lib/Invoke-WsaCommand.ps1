[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)][string]$Command,
    [Parameter(ValueFromRemainingArguments=$true)][object[]]$RemainingArguments
)
$ErrorActionPreference = 'Stop'

function Find-WsaEngineRoot {
    param([string]$Start)
    $current = [IO.Path]::GetFullPath($Start)
    while ($current) {
        if (Test-Path -LiteralPath (Join-Path $current 'powershell\WindowsSkills.Engine\WindowsSkills.Engine.psd1')) { return $current }
        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }
    if ($env:WINDOWS_ADMIN_ENGINE_ROOT -and (Test-Path -LiteralPath $env:WINDOWS_ADMIN_ENGINE_ROOT)) { return [IO.Path]::GetFullPath($env:WINDOWS_ADMIN_ENGINE_ROOT) }
    throw 'Cannot locate Windows Administration Skills Engine root.'
}

$repo = Find-WsaEngineRoot -Start $PSScriptRoot
$manifest = Join-Path $repo 'powershell\WindowsSkills.Engine\WindowsSkills.Engine.psd1'
Import-Module $manifest -Force -ErrorAction Stop

switch ($Command.ToLowerInvariant()) {
    'inventory' { & Get-WseSystemInventory @RemainingArguments; break }
    'health' { & Test-WseSystemHealth @RemainingArguments; break }
    'network' { & Get-WseNetworkSnapshot @RemainingArguments; break }
    'ad-health' { & Get-WseAdHealth @RemainingArguments; break }
    'security' { & Get-WseSecuritySnapshot @RemainingArguments; break }
    'storage' { & Get-WseStorageServiceSnapshot @RemainingArguments; break }
    'service' { & Get-WseStorageServiceSnapshot @RemainingArguments; break }
    'service-state' { & Invoke-WseServiceState @RemainingArguments; break }
    'events' { & Get-WseEventEvidence @RemainingArguments; break }
    'doctor' { & Test-WseEngine; break }
    'dns-test' {
        if (-not $RemainingArguments -or [string]$RemainingArguments[0] -match '^-') { throw 'Usage: wsa-dns-test <name> [DnsOnly] [server]' }
        $name=[string]$RemainingArguments[0]
        if (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue) { Resolve-DnsName -Name $name -ErrorAction Stop } else { [System.Net.Dns]::GetHostAddresses($name) }
        break
    }
    'port-test' {
        if ($RemainingArguments.Count -lt 2) { throw 'Usage: wsa-port-test <computer> <port>' }
        if (-not (Get-Command Test-NetConnection -ErrorAction SilentlyContinue)) { throw 'Test-NetConnection is unavailable.' }
        Test-NetConnection -ComputerName ([string]$RemainingArguments[0]) -Port ([int]$RemainingArguments[1]) -InformationLevel Detailed
        break
    }
    'listeners' { Get-NetTCPConnection -State Listen -ErrorAction Stop | Sort-Object LocalPort | Select-Object LocalAddress,LocalPort,OwningProcess,CreationTime; break }
    'ad-replication' { if (-not (Get-Command repadmin.exe -ErrorAction SilentlyContinue)) { throw 'repadmin.exe is unavailable.' }; & repadmin.exe /replsummary; exit $LASTEXITCODE }
    'ad-fsmo' { Import-Module ActiveDirectory -ErrorAction Stop; $d=Get-ADDomain; $f=Get-ADForest; [pscustomobject]@{Domain=$d.DNSRoot;PDCEmulator=$d.PDCEmulator;RIDMaster=$d.RIDMaster;InfrastructureMaster=$d.InfrastructureMaster;SchemaMaster=$f.SchemaMaster;DomainNamingMaster=$f.DomainNamingMaster}; break }
    'ad-dcs' { Import-Module ActiveDirectory -ErrorAction Stop; Get-ADDomainController -Filter * | Select-Object HostName,Site,IPv4Address,IsGlobalCatalog,OperationMasterRoles; break }
    'gp-result' { & gpresult.exe /r @RemainingArguments; exit $LASTEXITCODE }
    'firewall-status' { Get-NetFirewallProfile -ErrorAction Stop | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,AllowInboundRules,AllowLocalFirewallRules; break }
    'defender-status' { Get-MpComputerStatus -ErrorAction Stop | Select-Object AMServiceEnabled,AntivirusEnabled,AntispywareEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated,QuickScanAge,FullScanAge; break }
    'bitlocker-status' { Get-BitLockerVolume -ErrorAction Stop | Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionMethod,EncryptionPercentage; break }
    'hotfixes' { Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object HotFixID,Description,InstalledBy,InstalledOn; break }
    'pending-reboot' { $r=Get-WseSystemInventory; $r.After.PendingReboot; break }
    'software' {
        $roots=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
        Get-ItemProperty -Path $roots -ErrorAction SilentlyContinue | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate,PSPath | Sort-Object DisplayName -Unique
        break
    }
    'drivers' { Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop | Select-Object DeviceName,DeviceClass,Manufacturer,DriverProviderName,DriverVersion,DriverDate,InfName,IsSigned | Sort-Object DeviceClass,DeviceName; break }
    'certificates' { Get-ChildItem Cert:\LocalMachine\My -ErrorAction Stop | Select-Object Subject,Issuer,Thumbprint,NotBefore,NotAfter,HasPrivateKey,EnhancedKeyUsageList | Sort-Object NotAfter; break }
    'local-accounts' { if(Get-Command Get-LocalUser -ErrorAction SilentlyContinue){Get-LocalUser|Select-Object Name,SID,Enabled,LastLogon,PasswordExpires,UserMayChangePassword}else{Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True'|Select-Object Name,SID,Disabled,Lockout,PasswordExpires}; break }
    'local-admins' { if(-not (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue)){throw 'Get-LocalGroupMember is unavailable.'};$sid=New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544');$name=$sid.Translate([System.Security.Principal.NTAccount]).Value.Split('\')[-1];Get-LocalGroupMember -Group $name|Select-Object Name,SID,ObjectClass,PrincipalSource; break }
    'time-status' { & w32tm.exe /query /status; $first=$LASTEXITCODE; & w32tm.exe /query /source; if($first -ne 0){exit $first}else{exit $LASTEXITCODE} }
    'audit-policy' { & auditpol.exe /get /category:*; exit $LASTEXITCODE }
    'shares' { Get-SmbShare -ErrorAction Stop | Select-Object Name,Path,Description,EncryptData,FolderEnumerationMode,ConcurrentUserLimit; break }
    'smb-sessions' { Get-SmbSession -ErrorAction Stop | Select-Object SessionId,ClientComputerName,ClientUserName,NumOpens,Dialect,Encrypted,ContinuouslyAvailable; break }
    'open-files' { Get-SmbOpenFile -ErrorAction Stop | Select-Object FileId,SessionId,ClientComputerName,ClientUserName,Path,Permissions; break }
    'tasks' { Get-ScheduledTask -ErrorAction Stop | Select-Object TaskPath,TaskName,State,Author,Description; break }
    'iis-status' { Import-Module WebAdministration -ErrorAction Stop; [pscustomobject]@{Sites=@(Get-Website | Select-Object Name,State,PhysicalPath,Bindings);ApplicationPools=@(Get-ChildItem IIS:\AppPools | Select-Object Name,State,ManagedRuntimeVersion,ManagedPipelineMode)}; break }
    'hyperv-status' { Import-Module Hyper-V -ErrorAction Stop; [pscustomobject]@{VMs=@(Get-VM | Select-Object VMId,Name,State,Status,CPUUsage,MemoryAssigned,Uptime);Switches=@(Get-VMSwitch | Select-Object Id,Name,SwitchType);Checkpoints=@(Get-VM | Get-VMSnapshot -ErrorAction SilentlyContinue | Select-Object VMName,Name,CreationTime,SnapshotType)}; break }
    'wsl-status' { & wsl.exe --status; & wsl.exe --list --verbose; exit $LASTEXITCODE }
    'processes' { Get-Process -ErrorAction Stop | Sort-Object CPU -Descending | Select-Object -First 50 Id,ProcessName,CPU,WorkingSet64,PrivateMemorySize64,StartTime; break }
    'startup' { Get-CimInstance Win32_StartupCommand -ErrorAction Stop | Select-Object Name,Command,Location,User; break }
    'performance-sample' {
        $sets=@('\Processor(_Total)\% Processor Time','\Memory\Available MBytes','\PhysicalDisk(_Total)\Avg. Disk sec/Transfer')
        Get-Counter -Counter $sets -SampleInterval 1 -MaxSamples 5 -ErrorAction Stop
        break
    }
    'backup-status' {
        $service=Get-Service -Name wbengine -ErrorAction SilentlyContinue
        $features=if(Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue){Get-WindowsFeature Windows-Server-Backup -ErrorAction SilentlyContinue}else{$null}
        [pscustomobject]@{WindowsServerBackupFeature=$features;BlockLevelBackupService=$service;RecoveryTest='NOT_ASSESSED'}
        break
    }
    'vss-status' { & vssadmin.exe list writers; exit $LASTEXITCODE }
    'containers-status' {
        foreach($name in @('docker','podman','containerd','nerdctl')){$commandInfo=Get-Command $name -ErrorAction SilentlyContinue;[pscustomobject]@{Runtime=$name;Available=[bool]$commandInfo;Path=if($commandInfo){$commandInfo.Source}else{$null};LiveState='NOT_ASSESSED'}}
        break
    }
    'toolchain' {
        $names=@('powershell','pwsh','python','py','git','dotnet','node','npm','winget','wsl','code')
        $names|ForEach-Object{$c=Get-Command $_ -ErrorAction SilentlyContinue;[pscustomobject]@{Name=$_;Available=[bool]$c;Path=if($c){$c.Source}else{$null};Version='NOT_ASSESSED'}}
        break
    }
    'list' { & (Join-Path $repo 'scripts\windows-admin.ps1') list; exit $LASTEXITCODE }
    'route' { & (Join-Path $repo 'scripts\windows-admin.ps1') route @RemainingArguments; exit $LASTEXITCODE }
    'validate' {
        foreach($script in @('validate_engine.py','routing_smoke_test.py','source_ingestion_guardrail.py','validate_command_tree.py')){& python -X utf8 (Join-Path $repo ('scripts\'+$script));if($LASTEXITCODE){exit $LASTEXITCODE}}
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\test-powershell-syntax.ps1');exit $LASTEXITCODE
    }
    'evidence-validate' { if(-not $RemainingArguments){throw 'Usage: wsa-evidence-validate <evidence-directory>'};& (Join-Path $repo 'scripts\windows-admin.ps1') validate-evidence @RemainingArguments; exit $LASTEXITCODE }
    'fleet-validate' { if(-not $RemainingArguments){throw 'Usage: wsa-fleet-validate <manifest.json>'};& python -X utf8 (Join-Path $repo 'scripts\validate_fleet_manifest.py') @RemainingArguments; exit $LASTEXITCODE }
    default { throw "Unknown wsa command '$Command'. Run wsa-list or wsa-route." }
}
