# Specify the path to the Dell OS Recovery Tool
$downloadURI = "https://raw.githubusercontent.com/Glenn-Halls/PowerShellScripting/refs/heads/main/Tools/Packages/Dell-OS-Recovery-Tool_WFFJR_WIN64_2.4.2.2193_A00.EXE"
$executable = "C:\Temp\SupportAssistOSR_64_2.4.2.2193.exe"

Write-Output "This script will install or update Dell OS Recovery Tool"

#Download and install Dell OS Recovery Tool silently
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadURI -Outfile $executable
& $executable /S
Start-Sleep 300
Remove-Item $executable

# Check for installation of Dell OS Recovery Tool
$dellInstall = Get-WmiObject -class Win32_product | Where-Object Name -eq "Dell OS Recovery Tool"

Write-Output "Script Completed:"
# Output result of installation
if ($null -eq $dellInstall) {
    # if not installed
    Write-Output "Dell OS Recovery Tool is not installed..."
} else {
    # if installed display version
    $installVersion = $dellInstall.Version.ToString()
    Write-Output "Dell OS Recovery Tool is version $installVersion"
}
