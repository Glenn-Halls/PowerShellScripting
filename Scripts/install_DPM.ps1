# Specify the path to the Dell Display and Peripheral Manager executable
$ddpmPath = "$env:ProgramFiles\Dell\Dell Peripheral Manager\dpm.exe"
$downloadURI = "https://exmchw.dm.files.1drv.com/y4mgHxn_JaUB8pxp3oeIp5ykM8Zd91raYMZ406DGS8EXpWtx_wR0nvdGmFCzDguZtj7i-IYRqiBlEZ5vhRIZRLobIBVJXZo9osd6Z9ZWwuNsxCDM3jdPfGFHoxdPH7-3ZQisza054lr-C6tKVB20UnifdGOf2YX7OvayidLTR98OrESEwHYxjNEItwfvuNeRL57XS9rhiNtseuGtnse3a0edeWixKnM9iGyEINHEmwYaEo"
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
