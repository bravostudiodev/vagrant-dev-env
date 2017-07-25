$ErrorActionPreference = "Stop"

function Install-Hotfix
{
    param ([string]$hotfixUrl)
    $hotfixFilename = $hotfixUrl.Split('/')[-1]
    $hotfixFilepath = "C:\Windows\Temp\$hotfixFilename.zip"
    (new-object net.WebClient).DownloadFile($hotfixUrl, $hotfixFilepath) | Out-Default
    # [System.IO.Compression.ZipFile]::ExtractToDirectory($filepath, "C:\Windows\Temp")

    $shell= New-Object -Com Shell.Application
    ForEach($item In $shell.NameSpace("$hotfixFilepath").Items()) {
        $itemPath = $item.Path.substring($hotfixFilepath.Length)
        If ($item.Path -Like "*.msu")
        {
            $shell.NameSpace("C:\Windows\Temp\").CopyHere($item) | Out-Default
            $name = $item.Name
            $path = "C:\Windows\Temp\$name.msu"
            Start-Process -FilePath wusa -ArgumentList $path,'/quiet','/norestart' -Wait -NoNewWindow | Out-Default
        }
    }
}

Write-Output "Powershell 5" | Out-Default
Install-Hotfix "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip"

# Write-Output "Setting up winrm" | Out-Default
# Enable-WSManCredSSP -Force -Role Server | Out-Default
# netsh advfirewall firewall add rule name="WINRM-HTTP-In-TCP-PUBLIC" dir=in action=allow remoteip=any | Out-Default
# netsh advfirewall firewall add rule name="RemoteDesktop-UserMode-In-TCP" dir=in action=allow enable=Yes | Out-Default

# Enable-PSRemoting -Force | Out-Default
# winrm set winrm/config/client/auth '@{Basic="true"}'  | Out-Default
# winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Default
# winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Default
# winrm set winrm/config '@{MaxTimeoutms="1800000"}' | Out-Default
# winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}' | Out-Default
# winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}' | Out-Default

# Write-Output "winrm setup complete" | Out-Default
# Write-Output "Sleeping for 1 minute, then restarting" | Out-Default
# start-sleep -s 60
