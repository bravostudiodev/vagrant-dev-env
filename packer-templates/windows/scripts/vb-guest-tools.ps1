Write-Output "Installing Virtualbox Guest Additions"
Write-Output "Checking for Certificates in vBox ISO"
if(test-path E:\ -Filter *.cer)
{
  Get-ChildItem E:\cert -Filter *.cer | ForEach-Object { certutil -addstore -f "TrustedPublisher" $_.FullName }
}

$vbadditionslog = "C:\Windows\Temp\virtualbox-tools.log"
#Start-Process -FilePath "E:\VBoxWindowsAdditions.exe" -ArgumentList "/S /l $vbadditionslog /v`"/qn REBOOT=ReallySuppress`"" -Wait
Start-Process -FilePath "E:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait
# Get-Content $vbadditionslog
