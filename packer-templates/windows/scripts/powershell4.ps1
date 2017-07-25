$ErrorActionPreference = "Stop"

function Install-Update
{
    param ([string]$msuUrl)
    $msuFilename = $msuUrl.Split('/')[-1]
    $msuFilepath = "C:\Windows\Temp\$msuFilename"
    (new-object net.WebClient).DownloadFile($msuUrl, $msuFilepath) | Out-Default
    Start-Process -FilePath wusa -ArgumentList "$msuFilepath",'/quiet','/norestart' -Wait -NoNewWindow | Out-Default
}

# Write-Output "Powershell 3"
# Install-Update "http://download.microsoft.com/download/5/2/B/52B59966-3009-4F39-A99E-3732717BBE2A/Windows6.1-KB2506143-x64.msu"

Write-Output "Powershell 4.0" | Out-Default
Install-Update "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu"
