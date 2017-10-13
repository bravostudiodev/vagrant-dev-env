$ErrorActionPreference = "Stop"

Write-Output ".Net 4.5.2 ..." | Out-Default
function Choco-Install ($pkg) {
    Start-Process -FilePath C:\ProgramData\Chocolatey\bin\choco.exe -ArgumentList $('upgrade -dv -y ' + $pkg) -Wait -NoNewWindow
}

function EnsureKey {
    $item = $args[0] 
    if (!(Test-Path $item)) { New-Item $item -ItemType RegistryKey -Force | Out-Default }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function AddToEnvPath($dirNotExpanded) {
    $dir = [System.Environment]::ExpandEnvironmentVariables($dirNotExpanded);
    $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
    if (!$($currentPath).ToLower().Contains($($dir).ToLower())) {
        $currentPath += ";" + $dir
        [System.Environment]::SetEnvironmentVariable('Path', $currentPath, [System.EnvironmentVariableTarget]::Machine);
        $env:Path += ";" + $dir # This session Path
    }
}

########################################
# Disable Windows 10 automatic updates
#

# Give Administrators access to DefaultMediaCost registry key
$adjprivimport = '[DllImport("ntdll.dll")] public static extern int RtlAdjustPrivilege(ulong p, bool e, bool t, ref bool pe);'
$ntdll = Add-Type -Member $adjprivimport -Name NtDll -PassThru
$privileges = @{ SeTakeOwnership = 9; SeBackup =  17; SeRestore = 18 }
$ntdll::RtlAdjustPrivilege($privileges.SeTakeOwnership, $true, $false, [ref]$false) | Out-Null

$keyPath = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost'
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($keyPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$key.SetAccessControl($acl)

# Assign Full Controll permissions to Administrators on the key. 
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow") 
$acl.SetAccessRule($rule) 
$key.SetAccessControl($acl) 

# Set connection types in DefaultMediaCost to metered to prevent automatic updates
$keyMediaCost = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost'
EnsureKey $keyMediaCost
Set-ItemProperty -Path $keyMediaCost -Name Ethernet -Type "DWord" -Value 2 -Force | Out-Default
Set-ItemProperty -Path $keyMediaCost -Name WiFi -Type "DWord" -Value 2 -Force | Out-Default
Set-ItemProperty -Path $keyMediaCost -Name Default -Type "DWord" -Value 2 -Force | Out-Default

########################################
# Install Chocolatey
#
if ($(cmd /c "where choco.exe || echo NOT INSTALLED").contains("NOT INSTALLED")) {
    (New-Object System.Net.WebClient).DownloadFile("https://chocolatey.org/api/v2/package/chocolatey/", "C:/Windows/Temp/chocolatey.zip")
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:/Windows/Temp/chocolatey.zip", "C:/Windows/Temp/chocolatey")
    iex C:\Windows\Temp\chocolatey\tools\chocolateyInstall.ps1
    $chocoPath = [System.Environment]::GetEnvironmentVariable("ChocolateyInstall")
    if ($chocoPath -eq $null -or $chocoPath -eq '') {
        $chocoPath = "$env:ALLUSERSPROFILE\Chocolatey"
        if (!(Test-Path ($chocoPath))) {
            $chocoPath = "$env:SYSTEMDRIVE\ProgramData\Chocolatey"
        }
    }
    $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
    $chocoExePath = Join-Path $chocoPath 'bin'
    if (!$($currentPath).ToLower().Contains($($chocoExePath).ToLower())) {
        $currentPath += ";" + $chocoExePath
        [System.Environment]::SetEnvironmentVariable('Path', $currentPath, [System.EnvironmentVariableTarget]::Machine);
        $env:Path += ";" + $chocoExePath # This session Path
    }

    Write-Output 'Ensuring chocolatey.nupkg is in the lib folder'
    $chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
    if (![System.IO.Directory]::Exists($chocoPkgDir)) { [System.IO.Directory]::CreateDirectory($chocoPkgDir); }

    $nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
    Copy-Item 'C:\Windows\Temp\chocolatey.zip' "$nupkg" -Force -ErrorAction SilentlyContinue
}
# Upgrade chocolatey itself
Choco-Install -pkg "chocolatey"

########################################
# Install chocolatey packages
#
Choco-Install -pkg "googlechrome"
Choco-Install -pkg "firefox"
Choco-Install -pkg "selenium-chrome-driver"
Choco-Install -pkg "selenium-gecko-driver"
Choco-Install -pkg "selenium-ie-driver"
Choco-Install -pkg "selenium-edge-driver"
Choco-Install -pkg "jre8 /exclude:32"

########################################
# Enable autologon for vagrant user
#
$keyWinlogon = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
EnsureKey $keyWinlogon
Set-ItemProperty -Path $keyWinlogon -Name AutoAdminLogon -Type "DWord" -Value 1 -Force | Out-Default
Set-ItemProperty -Path $keyWinlogon -Name DefaultUserName -Value "vagrant" -Force | Out-Default
Set-ItemProperty -Path $keyWinlogon -Name DefaultPassword -Value "vagrant" -Force | Out-Default

########################################
# Download bravo selenium jars
#
$pathVerBsdev = "C:/versions-bsdev.txt"
$bsdevVersions = if([System.IO.File]::Exists($pathVerBsdev)){ Get-Content $pathVerBsdev } else { "" }
$hasMatchingLine = $bsdevVersions | %{$_ -match "C:/tools/selenium/selenium-server-standalone.jar"}
if ($hasMatchingLine -notcontains $true) {
    (New-Object System.Net.WebClient).DownloadFile("https://selenium-release.storage.googleapis.com/3.5/selenium-server-standalone-3.5.3.jar", "C:/tools/selenium/selenium-server-standalone.jar")
    "C:/tools/selenium/selenium-server-standalone.jar" >> $pathVerBsdev
}

$hasMatchingLine = $bsdevVersions | %{$_ -match "C:/tools/selenium/selenium-bravo-servlet.jar"}
if ($hasMatchingLine -notcontains $true) {
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/bravostudiodev/bravo-grid/releases/download/2.1/selenium-bravo-servlet-2.1-standalone.jar", "C:/tools/selenium/selenium-bravo-servlet.jar")
    "C:/tools/selenium/selenium-bravo-servlet.jar" >> $pathVerBsdev
}

########################################
# Add all components to system PATH
#
AddToEnvPath('%ProgramFiles(x86)%\Google\Chrome\Application')
AddToEnvPath('%ProgramFiles%\Mozilla Firefox')
AddToEnvPath('%SystemDrive%\tools\selenium')

@'
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) #0 hide console

# Again, make sure all networks belong to Private profile (same as before winrm connection was set up)
# This is needed in case some interface are added after winrm was set up
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$networkListManager.GetNetworkConnections() | foreach { $_.GetNetwork().SetCategory(1) }

$pidSelenium = Start-Process -FilePath java -ArgumentList '-jar "C:/tools/selenium/selenium-server-standalone.jar" -port 4444' -NoNewWindow -PassThru
$pidBravo = Start-Process -FilePath java -ArgumentList '-jar "C:/tools/selenium/selenium-bravo-servlet.jar" server 4480' -NoNewWindow -PassThru
$procs = $($pidSelenium; $pidBravo)
$procs | Wait-Process
'@ > "C:/tools/selenium/selenium_entry.ps1"

$keyAutorun = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
EnsureKey $keyAutorun
Set-ItemProperty -Path $keyAutorun -Name RunSelenium -Value '"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" C:/tools/selenium/selenium_entry.ps1' -Force | Out-Default

# Again, make sure all networks belong to Private profile (same as before winrm connection was set up)
# This is needed in case some interface are added after winrm was set up
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$networkListManager.GetNetworkConnections() | foreach { $_.GetNetwork().SetCategory(1) }

# Disable firewall on Private profile (allow unrestricted access to selenium / bravo servlet)
Set-NetFirewallProfile -Profile Private -Enabled False

# Disable hibernation
$keyPower = 'HKLM:\System\CurrentControlSet\Control\Power'
EnsureKey $keyPower
Set-ItemProperty -Path $keyPower -Name HibernateFileSizePercent -Type "DWord" -Value 0 -Force | Out-Default
Set-ItemProperty -Path $keyPower -Name HibernateEnabled -Type "DWord" -Value 0 -Force | Out-Default

# Disable ScreenSaver
$keyDesktop = 'HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop'
EnsureKey $keyDesktop
Set-ItemProperty -Path $keyDesktop -Name ScreenSaveActive -Type "DWord" -Value 0 -Force | Out-Default

# Activate High Performance power plan
$p = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"
Invoke-CimMethod -InputObject $p -MethodName Activate

# Turning off the Network Location Wizard 
EnsureKey "HKLM:\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"

# Enable file and printer sharing
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes' -Wait

# Enable RDP
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389' -Wait

# Allow TS Connections
$keyTS = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
EnsureKey $keyTS
Set-ItemProperty -Path $keyTS -Name fDenyTSConnections -Type "DWord" -Value 0 -Force | Out-Default

# Enable Windows 7 / 10 remote MMC
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall set rule group="remote administration" new enable=yes' -Wait
Start-Process -FilePath cmd -ArgumentList '/c','netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes' -Wait
