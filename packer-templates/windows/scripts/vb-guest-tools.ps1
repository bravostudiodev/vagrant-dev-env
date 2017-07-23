$ErrorActionPreference = "Stop"

Write-Output "Installing Virtualbox Guest Additions" | Out-Default
Write-Output "Checking for Certificates in vBox ISO" | Out-Default
if(test-path E:\ -Filter *.cer)
{
  Get-ChildItem E:\cert -Filter *.cer | ForEach-Object { certutil -addstore -f "TrustedPublisher" $_.FullName }
}

$vbadditionslog = "C:\Windows\Temp\virtualbox-tools.log"
#Start-Process -FilePath "E:\VBoxWindowsAdditions.exe" -ArgumentList "/S /l $vbadditionslog /v`"/qn REBOOT=ReallySuppress`"" -Wait
Start-Process -FilePath "E:\VBoxWindowsAdditions.exe" -ArgumentList '/S','/l','$vbadditionslog','/v"/qn REBOOT=ReallySuppress"' -Wait
Get-Content $vbadditionslog | Out-Default
