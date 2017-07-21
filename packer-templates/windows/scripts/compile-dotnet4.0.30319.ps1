
# http://support.microsoft.com/kb/2570538
# http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/

$dotnet32ngen = "$Env:Windir\microsoft.net\framework\v4.0.30319\ngen.exe"
if ((Test-Path $dotnet32ngen)) {
	Start-Process -FilePath $dotnet32ngen -ArgumentList 'update','/force','/queue' -Wait
	Start-Process -FilePath $dotnet32ngen -ArgumentList 'executequeueditems' -Wait
}

$dotnet64ngen = "$Env:Windir\microsoft.net\framework64\v4.0.30319\ngen.exe"
if ((Test-Path $dotnet64ngen)) {
	Start-Process -FilePath $dotnet64ngen -ArgumentList 'update','/force','/queue' -Wait
	Start-Process -FilePath $dotnet64ngen -ArgumentList 'executequeueditems' -Wait
}
