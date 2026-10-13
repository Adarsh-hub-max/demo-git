$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$runtimeRoot = Join-Path $projectRoot '.runtime'
$tomcatVersion = '10.1.61'
$tomcatName = "apache-tomcat-$tomcatVersion"
$tomcatRoot = Join-Path $runtimeRoot $tomcatName
$downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-10/v$tomcatVersion/bin/$tomcatName.zip"

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
    throw 'A JDK is required. Set JAVA_HOME to a Java 11+ installation and run this script again.'
}

New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
if (-not (Test-Path (Join-Path $tomcatRoot 'bin\catalina.bat'))) {
    $archive = Join-Path $runtimeRoot "$tomcatName.zip"
    Write-Host "Downloading Apache Tomcat $tomcatVersion..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archive
    Expand-Archive -Path $archive -DestinationPath $runtimeRoot -Force
    Remove-Item $archive -Force
}

$webAppRoot = Join-Path $tomcatRoot 'webapps\hibernate-learning-lab'
if (Test-Path $webAppRoot) {
    Remove-Item $webAppRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $webAppRoot -Force | Out-Null
foreach ($file in @('about.html', 'test.html', 'result.jsp', 'verify.jsp', 'styles.css')) {
    Copy-Item (Join-Path $projectRoot $file) $webAppRoot
}
$webInf = Join-Path $webAppRoot 'WEB-INF'
New-Item -ItemType Directory -Path $webInf -Force | Out-Null
Copy-Item (Join-Path $projectRoot 'src\main\webapp\WEB-INF\web.xml') $webInf

$tomcatProcess = Get-CimInstance Win32_Process -Filter "name = 'java.exe'" |
    Where-Object { $_.CommandLine -like "*catalina.base=$tomcatRoot*" }
if ($tomcatProcess) {
    $tomcatProcess | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
}

$httpPort = $null
foreach ($candidatePort in 8081..8090) {
    if (-not (Get-NetTCPConnection -LocalPort $candidatePort -State Listen -ErrorAction SilentlyContinue)) {
        $httpPort = $candidatePort
        break
    }
}
if (-not $httpPort) {
    throw 'Ports 8081 through 8090 are all in use. Free one of them and run this script again.'
}

$serverConfigPath = Join-Path $tomcatRoot 'conf\server.xml'
$serverConfig = Get-Content $serverConfigPath -Raw
$serverConfig = $serverConfig -replace '<Server port="8005"', '<Server port="18005"'
$serverConfig = $serverConfig -replace '<Connector port="8080"', "<Connector port=`"$httpPort`""
Set-Content -Path $serverConfigPath -Value $serverConfig -Encoding UTF8

Start-Process -FilePath (Join-Path $tomcatRoot 'bin\catalina.bat') -ArgumentList 'run' -WorkingDirectory (Join-Path $tomcatRoot 'bin')
Write-Host "Tomcat started. Open http://localhost:$httpPort/hibernate-learning-lab/about.html"
