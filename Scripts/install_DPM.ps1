# Specify the path to the Dell Display and Peripheral Manager executable
$ddpmPath = "$env:ProgramFiles\Dell\Dell Peripheral Manager\dpm.exe"
$downloadURI = "https://exmchw.dm.files.1drv.com/y4mJELfFbyeVGdzzPbiIo9lbJ_StlcntuT7xZXcVCr7oX4TqRLibZLGZ_4XzKZwgSREM8hNlst-itv2odbgqIYvvRw6wJV34f9s4QlwZinpN2ukgIeT_Hh0dOUfD4dEaNvOYNulcxy8j4cD994nekLNUcE1cQlZVkz9o1KeDaObhtLm_-08m83rP4jRcbVGY4QVdQ93x4Ue1dlcd-0fS3aWBw"
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
