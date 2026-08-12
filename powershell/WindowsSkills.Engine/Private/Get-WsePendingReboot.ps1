function Get-WsePendingReboot {
    [CmdletBinding()]
    param()

    $reasons = New-Object System.Collections.Generic.List[string]
    $keys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )
    foreach ($key in $keys) {
        if (Test-Path -LiteralPath $key) { $reasons.Add($key) }
    }
    try {
        $pending = (Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction Stop).PendingFileRenameOperations
        if ($pending) { $reasons.Add('PendingFileRenameOperations') }
    } catch { }

    [pscustomobject]@{ Required = ($reasons.Count -gt 0); Reasons = @($reasons) }
}
