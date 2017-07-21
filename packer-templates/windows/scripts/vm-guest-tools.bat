if "%PACKER_BUILDER_TYPE%" neq "virtualbox-iso" (
    echo "Packer build type is not virtualbox-iso"
    exit /b 1
)

:: There needs to be Oracle CA (Certificate Authority) certificates installed in order
:: to prevent user intervention popups which will undermine a silent installation.
cmd /c certutil -addstore -f "TrustedPublisher" A:\oracle-cert.cer

cmd /c "E:\VBoxWindowsAdditions.exe" /S /l "C:\Windows\Temp\virtualbox-tools.log" /v"/qn REBOOT=R"
set VBINSTALL_EXITCODE=%errorlevel%
if %VBINSTALL_EXITCODE% EQU 0 (
    echo "Installation was successful"
    exit /b 0
)
if %VBINSTALL_EXITCODE% EQU 3010 (
    echo "Installation was successful, Rebooting is needed"
    exit /b 0
)

echo "Installation failed: Error=%VBINSTALL_EXITCODE%"
type "C:\Windows\Temp\virtualbox-tools.log"
exit /b 3
