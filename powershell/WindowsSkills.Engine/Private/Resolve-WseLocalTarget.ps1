function Resolve-WseLocalTarget {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME)

    $localNames = @('.', 'localhost', '127.0.0.1', '::1', $env:COMPUTERNAME)
    if ($localNames -notcontains $ComputerName) {
        throw "Remote target '$ComputerName' is not enabled by the 0.1 local operation boundary. Use the remote-management skill and a lab-validated adapter."
    }

    $machineGuid = $null
    try {
        $machineGuid = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid -ErrorAction Stop).MachineGuid
    } catch {
        $machineGuid = $null
    }

    @{
        Kind = 'Local'
        Name = $env:COMPUTERNAME
        Fingerprint = $machineGuid
        ResolvedAt = [datetime]::UtcNow.ToString('o')
    }
}

function Test-WseIsAdministrator {
    [CmdletBinding()]
    param()
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
