Write-Output "This script will install or update Java to version 8.0.4410.7"

$initialJava = Get-CimInstance -ClassName CIM_Product -Filter "Name LIKE '%Java%' AND NOT Name LIKE '%Auto%'"
$initialJavaVersion = if ($null -eq $initialJava) {"NOT INSTALLED"} else {$initialJava.Version}

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://github.com/Glenn-Halls/PowerShellScripting/raw/refs/heads/main/Tools/Packages/MSI/Java/jre1.8.0_44164.msi -Outfile C:\Temp\java.msi
msiexec /i C:\Temp\java.msi JU=0 JAVAUPDATE=0 AUTOUPDATECHECK=1 REMOVEOUTOFDATEJRES=1 RebootYesNo=No /qn
Start-Sleep 300
Remove-Item c:\temp\java.msi

$finalJava = Get-CimInstance -ClassName CIM_Product -Filter "Name LIKE '%Java%' AND NOT Name LIKE '%Auto%'"
$finalJavaVersion = $finalJava.Version

Write-Output "Initial Java version was $initialJavaVersion --> Java is now $finalJavaVersion"
