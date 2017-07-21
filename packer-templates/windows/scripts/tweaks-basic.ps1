# NOTE: WinRM and Powershell Execution Policy are configured in Autounattend.xml
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Start-Process -FilePath \"$Env:SystemRoot\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe\" -ArgumentList '-Command','"&Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}"' -Wait

function EnureKey {
    $item = $args[0] 
    if (!(Test-Path $item)) { New-Item $item -ItemType RegistryKey -Force | Out-Null }
}

Write-Output "== Performing basic tweaks =="

Write-Output "Disabling hibernation..."

$keyPower = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
EnureKey $keyPower
Set-ItemProperty -Path $keyPower -Name HibernateFileSizePercent -Type "DWord" -Value 0 -Force | Out-Null
Set-ItemProperty -Path $keyPower -Name HibernateEnabled -Type "DWord" -Value 0 -Force | Out-Null

Write-Output "Disable Auto-logon"
$keyWinlogon = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
EnureKey $keyWinlogon
Set-ItemProperty -Path $keyWinlogon -Name AutoAdminLogon -Type "DWord" -Value 0 -Force | Out-Null

Write-Output "Enable RDP"
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389' -Wait
Write-Output "Allow TS Connections"
$keyTS = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
EnureKey $keyTS
Set-ItemProperty -Path $keyTS -Name fDenyTSConnections -Type "DWord" -Value 0 -Force | Out-Null
