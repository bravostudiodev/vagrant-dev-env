# NOTE: WinRM and Powershell Execution Policy are configured in Autounattend.xml
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Start-Process -FilePath \"$Env:SystemRoot\\SysWOW64\\WindowsPowerShell\\v1.0\\powershell.exe\" -ArgumentList '-Command','"&Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}"' -Wait

Write-Output "== Performing basic tweaks =="

Write-Output "Disabling hibernation..."
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateFileSizePercent /t REG_DWORD /d 0 /f
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateEnabled /t REG_DWORD /d 0 /f

Write-Output "Disable Auto-logon"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

Write-Output "Enable RDP"
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
Write-Output "Allow TS Connections"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
