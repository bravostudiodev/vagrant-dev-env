Write-Host "Cleaning updates.." | Out-Default
Stop-Service -Name wuauserv -Force | Out-Default
Remove-Item c:\Windows\SoftwareDistribution\Download\* -Recurse -Force | Out-Default
Start-Service -Name wuauserv | Out-Default

@(
    "$env:localappdata\temp\*",
    "$env:windir\temp\*"
) | % {
    if(Test-Path $_) {
        Write-Host "Removing $_" | Out-Default
        try {
            Start-Process -FilePath cmd -ArgumentList '/c','Takeown /d Y /R /f $_' -Wait -NoNewWindow | Out-Default
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Default
            Remove-Item $_ -Recurse -Force | Out-Default
        } catch { $global:error.RemoveAt(0) }
    }
}
