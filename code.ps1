<#
    This script will pull information about user profiles on a target PC, to determine the size of the current user, and other users' profiles.
    This information is helpful prior to deployment of a replacement PC, or to determine space requirements for data backup.
    In the future, this will also display the size of a user's OneDrive and Outlook folders, which can be excluded from a backup if a
    user is happy to sync these with the cloud post-deployment.
#>

Set-StrictMode -Version latest


$userArray = Get-ChildItem -Path C:\Users
$pcInfo = (Get-WmiObject -Class Win32_ComputerSystem)
$pcName = $pcInfo.Name
$userName = (Get-WmiObject -Class Win32_ComputerSystem).UserName.Split("\")[-1]
$numUsers = $userArray.Length
$profileSize = [math]::Round(( Get-Childitem -Path C:\users -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property "Length" -Sum ).Sum / 1GB)
$userProfileSize = [math]::Round(( Get-Childitem -Path C:\users\$userName -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property "Length" -Sum ).Sum / 1GB, 2)

Write-Output "There are $numUsers user profiles on PC '$pcName' totalling $profileSize GB user data."
Write-Output "The current logged in user is $userName, with a profile size of $userProfileSize GB."
