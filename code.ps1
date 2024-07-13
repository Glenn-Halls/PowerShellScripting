<#
    This script will pull information about user profiles on a target PC, to determine the size of the current user, and other users' profiles.
    This information is helpful prior to deployment of a replacement PC, or to determine space requirements for data backup.
    In the future, this will also display the size of a user's OneDrive and Outlook folders, which can be excluded from a backup if a
    user is happy to sync these with the cloud post-deployment.
#>

Set-StrictMode -Version latest

# Function to get size of folder including subfolders with option to exclude OneDrive Folder
Function Get-Size {
    param (
        [string] $path,
        [boolean] $excludeOneDrive = $false
    ) 
        return ( Get-Childitem -Path $path -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property "Length" -Sum ).Sum
}

# PC / Login data
$pcInfo = (Get-WmiObject -Class Win32_ComputerSystem)
$pcName = $pcInfo.Name
$userName = $pcInfo.UserName.Split("\")[-1]

# Profile data
$profileArray = Get-Childitem -Path C:\users\
$numUsers = $profileArray.Length

# Create user Vs non-user profile Arrays
$userArray = New-Object 'System.Collections.ArrayList'
$nonUserArray = New-Object 'System.Collections.ArrayList'
foreach($i in $profileArray) {
    if($i.Name -eq $userName) {
        $userArray += $i
    } else {
        $nonUserArray += $i
    }
}

# Calculate size of user, non-user and all profiles
$userProfileSize = Get-Size("C:\users\$userName")
$nonUserProfileSize = 0.0
foreach($i in $nonUserArray) {
    $nonUserProfileSize += Get-Size("C:\users\$i")
}
$allUserProfileSize = $userProfileSize + $nonUserProfileSize

# Check for user OneDrive Folder & measure size if it exists
$oneDriveExists = Test-Path -Path C:\users\$userName\OneDrive
$oneDriveSize = 0.0
if ($oneDriveExists) {
    $oneDriveSize = Get-Size("C:\users\$userName\OneDrive")
}

# Format display output
$userSizeDisplay = [math]::Round(($userProfileSize) / 1GB, 2)
$allUserSizeDisplay = [math]::Round(($allUserProfileSize) / 1GB, 0)

# Output Results
Write-Output "There are $numUsers user profiles on PC '$pcName' totalling $allUserSizeDisplay GB user data."
Write-Output "The current logged in user is $userName, with a profile size of $userSizeDisplay GB."
if ($oneDriveExists) { Write-Output "OneDrive DOES exist...  and is $oneDriveSize in size..." }
