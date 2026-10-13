$tomcatRoot = Join-Path $PSScriptRoot '.runtime\apache-tomcat-10.1.61'
$shutdownScript = Join-Path $tomcatRoot 'bin\shutdown.bat'
if (-not (Test-Path $shutdownScript)) {
    Write-Host 'The local Tomcat runtime is not installed.'
    exit 0
}
$tomcatProcess = Get-CimInstance Win32_Process -Filter "name = 'java.exe'" |
    Where-Object { $_.CommandLine -like "*catalina.base=$tomcatRoot*" }
if (-not $tomcatProcess) {
    Write-Host 'This project Tomcat instance is not running.'
    exit 0
}
Start-Process -FilePath $shutdownScript -WorkingDirectory (Join-Path $tomcatRoot 'bin') -Wait
Write-Host 'Tomcat shutdown requested.'
