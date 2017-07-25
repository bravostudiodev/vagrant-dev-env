$ErrorActionPreference = "Stop"

function Install-Update
{
    param ([string]$msuUrl)
    $msuFilename = $msuUrl.Split('/')[-1]
    $msuFilepath = "C:\Windows\Temp\$msuFilename"
    (new-object net.WebClient).DownloadFile($msuUrl, $msuFilepath) | Out-Default
    Start-Process -FilePath wusa -ArgumentList "$msuFilepath",'/quiet','/norestart' -Wait -NoNewWindow | Out-Default
}

Write-Output "Fix Win7 SP1 slow update https://support.microsoft.com/en-us/kb/3102810" | Out-Default
Install-Update "https://download.microsoft.com/download/F/A/A/FAABD5C2-4600-45F8-96F1-B25B137E3C87/Windows6.1-KB3102810-x64.msu"
