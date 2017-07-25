$ErrorActionPreference = "Stop"

Write-Output ".Net 4.5.2 ..." | Out-Default
# Release   Version
# 378389	.NET Framework 4.5
# 378675	.NET Framework 4.5.1 installed with Windows 8.1 or Windows Server 2012 R2
# 378758	.NET Framework 4.5.1 installed on Windows 8, Windows 7 SP1, or Windows Vista SP2
# 379893	.NET Framework 4.5.2
$dotnet_info = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue
if ($dotnet_info.Release -lt 379893)
{
    Write-Output "installing ..." | Out-Default
    $exeUrl = "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
    $exeFilename = $exeUrl.Split('/')[-1]
    $exeFilepath = "C:\Windows\Temp\$exeFilename"
    Write-Output "Downloading .Net 4.5.2" | Out-Default
    (new-object net.WebClient).DownloadFile($exeUrl, $exeFilepath) | Out-Default
    Write-Output "Installing .NET 4.5.2" | Out-Default
    Start-Process -FilePath $exeFilepath -ArgumentList '/Passive /norestart' -Wait -NoNewWindow | Out-Default
    Write-Output "dotnet 4.5.2 installed" | Out-Default
} 
else 
{
    Write-Output ".NET 4.5.2 already installed, no changes" | Out-Default
}
