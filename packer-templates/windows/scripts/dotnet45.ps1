$ErrorActionPreference = "Stop"

Write-Output ".Net 4.5 ..." | Out-Default

# The existence of the Release DWORD indicates that the .NET Framework 4.5 or newer has been installed on that computer.
$dotnet_info = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue
if ($dotnet_info -eq $null)
{
    Write-Output "installing ..." | Out-Default
    $exeUrl = "https://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe"
    $exeFilename = $exeUrl.Split('/')[-1]
    $exeFilepath = "C:\Windows\Temp\$exeFilename"
    Write-Output "Downloading .Net 4.5" | Out-Default
    (new-object net.WebClient).DownloadFile($exeUrl, $exeFilepath) | Out-Default
    Write-Output "Installing .NET 4.5" | Out-Default
    Start-Process -FilePath $exeFilepath -ArgumentList '/q /norestart' -Wait -NoNewWindow | Out-Default
}
else 
{
    Write-Output ".NET 4.5 is already installed", no changes"" | Out-Default
}
