# NOTE: WinRM and Powershell Execution Policy are configured in Autounattend.xml
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Start-Process -FilePath \"$Env:SystemRoot\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe\" -ArgumentList '-Command','"&Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}"' -Wait -NoNewWindow

$ErrorActionPreference = "Stop"

function EnsureKey {
    $item = $args[0] 
    if (!(Test-Path $item)) { New-Item $item -ItemType RegistryKey -Force | Out-Default }
}

Write-Output "== Performing basic system tweaks ==" | Out-Default

Write-Output "Disabling hibernation..." | Out-Default

$keyPower = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
EnsureKey $keyPower
Set-ItemProperty -Path $keyPower -Name HibernateFileSizePercent -Type "DWord" -Value 0 -Force | Out-Default
Set-ItemProperty -Path $keyPower -Name HibernateEnabled -Type "DWord" -Value 0 -Force | Out-Default

Write-Output "Disable Auto-logon" | Out-Default
$keyWinlogon = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
EnsureKey $keyWinlogon
Set-ItemProperty -Path $keyWinlogon -Name AutoAdminLogon -Type "DWord" -Value 0 -Force | Out-Default

Write-Output "Enable File Sharing" | Out-Default
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes' -Wait | Out-Default
Write-Output "Enable RDP" | Out-Default
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389' -Wait | Out-Default
Write-Output "Allow TS Connections" | Out-Default
$keyTS = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
EnsureKey $keyTS
Set-ItemProperty -Path $keyTS -Name fDenyTSConnections -Type "DWord" -Value 0 -Force | Out-Default
