# Specify the path to the Dell OS Recovery Tool
$downloadURI = "https://d0frqa.dm.files.1drv.com/y4mziqFAZA5RvG2ciXerng4CYfQ2oBvgQkdo-JNuQnNMxVfUKaK7fFS4LceFF1MX7TAAlCWn7ycjr8mz-wCtPtxjOwJdlc55-fPGxWOLG8ikUVTjIXDNBimK3RQIgeZ3LDE-tA0fh9Jg4t7w4dn0_0qP60LXkxMoohstmCpYsayPSDDPaoegbgL1KhrMqLz2Z7sN1LTB8cDeNFsNs6n6ibpi1S05k1s90gyN8RMlyRYIV8"
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
