Write-Output "== Performing minor tweaks =="

Write-Output "Enable File Sharing"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
Write-Output "Show file extensions in Explorer"
reg ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v HideFileExt /t REG_DWORD /d 0 /f
Write-Output "Enable QuickEdit mode"
reg ADD HKCU\Console /v QuickEdit /t REG_DWORD /d 1 /f
Write-Output "Show Run command in Start Menu"
reg ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v Start_ShowRun /t REG_DWORD /d 1 /f
Write-Output "Show Administrative Tools in Start Menu"
reg ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v StartMenuAdminTools /t REG_DWORD /d 1 /f
