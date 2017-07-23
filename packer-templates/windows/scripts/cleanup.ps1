Write-Host "Cleaning updates.."
Stop-Service -Name wuauserv -Force
Remove-Item c:\Windows\SoftwareDistribution\Download\* -Recurse -Force
Start-Service -Name wuauserv

@(
    "$env:localappdata\temp\*",
    "$env:windir\temp\*"
) | % {
        if(Test-Path $_) {
            Write-Host "Removing $_"
            try {
                Start-Process -FilePath cmd -ArgumentList '/c','Takeown /d Y /R /f $_' -Wait -NoNewWindow
                Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
                Remove-Item $_ -Recurse -Force | Out-Null
            } catch { $global:error.RemoveAt(0) }
        }
    }
