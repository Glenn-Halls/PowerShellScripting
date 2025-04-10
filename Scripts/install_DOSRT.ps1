# Specify the path to the Dell OS Recovery Tool
$downloadURI = "https://d0frqa.dm.files.1drv.com/y4mvSVNspfSBTnn5L-IomhxsYcCBM5pzZXheY4ziNCJ9ZygR9Mp964sy7LpiKsNVJtXOQW-kB8TA28uG6-zq3SQZO-1kBYI7CJ9G8peWt5ETFTAzX4z91CIu7GaC1IJ483NJmxHyoSO7epeHcHGnaKGYXscOip4LT_WLCsuBsNmHZunnEr7t3sEJ1ASS4ZB3rA3MHBTLGIQyzccxuESL3naQaai83EjtV84l8bZN3qnodg?AVOverride=1"
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
