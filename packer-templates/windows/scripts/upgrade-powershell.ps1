$ErrorActionPreference = "Stop"

function Install-DotNet45
{
    if(Get-ItemProperty 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction SilentlyContinue | Out-Null) 
    {
        $exeUrl = "https://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe"
        $exeFilename = $exeUrl.Split('/')[-1]
        $exeFilepath = "C:\Windows\Temp\$exeFilename"
        (new-object net.WebClient).DownloadFile($exeUrl, $exeFilepath) | Out-Null
        Start-Process -FilePath $exeFilepath -ArgumentList '/q /norestart' -Wait -NoNewWindow | Out-Default
    }
}

function Install-Update
{
    param ([string]$msuUrl)
    $msuFilename = $msuUrl.Split('/')[-1]
    $msuFilepath = "C:\Windows\Temp\$msuFilename"
    (new-object net.WebClient).DownloadFile($msuUrl, $msuFilepath) | Out-Null
    Start-Process -FilePath wusa -ArgumentList "$msuFilepath",'/quiet','/norestart' -Wait -NoNewWindow | Out-Default
}

function Install-Hotfix
{
    param ([string]$hotfixUrl)
    $hotfixFilename = $hotfixUrl.Split('/')[-1]
    $hotfixFilepath = "C:\Windows\Temp\$hotfixFilename.zip"
    (new-object net.WebClient).DownloadFile($hotfixUrl, $hotfixFilepath) | Out-Null
    # [System.IO.Compression.ZipFile]::ExtractToDirectory($filepath, "C:\Windows\Temp")

    $shell= New-Object -Com Shell.Application
    ForEach($item In $shell.NameSpace("$hotfixFilepath").Items()) {
        $itemPath = $item.Path.substring($hotfixFilepath.Length)
        If ($item.Path -Like "*.msu")
        {
            $shell.NameSpace("C:\Windows\Temp\").CopyHere($item) | Out-Null
            $name = $item.Name
            $path = "C:\Windows\Temp\$name.msu"
            Start-Process -FilePath wusa -ArgumentList $path,'/quiet','/norestart' -Wait -NoNewWindow | Out-Default
        }
    }
}

# Write-Output "Fix Win7 SP1 slow update https://support.microsoft.com/en-us/kb/3102810"
# Install-Update "https://download.microsoft.com/download/F/A/A/FAABD5C2-4600-45F8-96F1-B25B137E3C87/Windows6.1-KB3102810-x64.msu"

Write-Output "DotNet 4.5" | Out-Default
Install-DotNet45

# Write-Output "Powershell 3"
# Install-Update "http://download.microsoft.com/download/5/2/B/52B59966-3009-4F39-A99E-3732717BBE2A/Windows6.1-KB2506143-x64.msu"

Write-Output "Powershell 5.1" | Out-Default
Install-Hotfix "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip"

Write-Output "Setting up winrm" | Out-Default
Enable-WSManCredSSP -Force -Role Server | Out-Default
#Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any | Out-Default
netsh advfirewall firewall add rule name="WINRM-HTTP-In-TCP-PUBLIC" dir=in action=allow remoteip=any | Out-Default
netsh advfirewall firewall add rule name="RemoteDesktop-UserMode-In-TCP" dir=in action=allow enable=Yes | Out-Default

Enable-PSRemoting -Force | Out-Default
winrm set winrm/config/client/auth '@{Basic="true"}'  | Out-Default
winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Default
winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Default
winrm set winrm/config '@{MaxTimeoutms="1800000"}' | Out-Default
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}' | Out-Default
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}' | Out-Default

Write-Output "winrm setup complete" | Out-Default
net stop winrm
Write-host "Sleeping for 1 minute, then restarting"
start-sleep -s 60
