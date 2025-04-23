# Specify the path to the Dell Display and Peripheral Manager executable
$ddpmPath = "$env:ProgramFiles\Dell\Dell Peripheral Manager\dpm.exe"
$downloadURI = "https://matix.li/3f1512b983ac"
$executable = "C:\Temp\DDPM-Setup_2.0.1.16.exe"

Write-Output "This script will install or update Dell Peripheral Manager"

#Download and install Dell Peripheral Manager silently
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadURI -Outfile $executable
& $executable /S
Start-Sleep 700
Remove-Item $executable

Write-Output "Script Completed:"

# Check if the executable exists
if (Test-Path $ddpmPath) {
    # Get the version information from the executable
    $ddpmVersion = (Get-Item $ddpmPath).VersionInfo.FileVersion

    # Display the version information
    Write-Host "Dell Display and Peripheral Manager Version: $($ddpmVersion)"
} else {
    # Display error if DDPM not found
    Write-Host "ERROR: Dell Display and Peripheral Manager not found."
}
