:: vagrant public key
copy a:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys || goto :error

:: disable auto-logon
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f || goto :error

:: enable RDP
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389 || goto :error
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f || goto :error

:: compile dotnet assemblies
::http://support.microsoft.com/kb/2570538
::http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/
if exist %windir%\microsoft.net\framework\v4.0.30319\ngen.exe (
	%windir%\microsoft.net\framework\v4.0.30319\ngen.exe update /force /queue
	%windir%\microsoft.net\framework\v4.0.30319\ngen.exe executequeueditems
)
if exist %windir%\microsoft.net\framework64\v4.0.30319\ngen.exe (
	%windir%\microsoft.net\framework64\v4.0.30319\ngen.exe update /force /queue
	%windir%\microsoft.net\framework64\v4.0.30319\ngen.exe executequeueditems
)
:: continue even if ngen fails
exit /b 0
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
