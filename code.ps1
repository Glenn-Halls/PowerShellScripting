<#
    This script will pull information about user profiles on a target PC, to determine the size of the current user, and other users' profiles.
    It will also show the user's OneDrive folder size (if it exists) and the size taken up by any .PST files.
    This information is helpful prior to deployment of a replacement PC, to determine space requirements for data backup, or to help a user free
    up space on their PC.
#>

Set-StrictMode -Version latest

# Get size of folder including subfolders with option to exclude OneDrive Folder.
Function Get-Size {
    param (
        [string] $path,
        [boolean] $excludeOneDrive = $false,
        [boolean] $excludePst = $false
    ) 
        return ( Get-Childitem -Path $path -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property "Length" -Sum ).Sum
}

# Transform size from [integer] bytes to [string] size for display to user, with optional decimal places if over 1GB.
Function Format-Size {
    param (
        [long] $size,
        [int] $decimalPlaces = 0
    )

    if ($size -ge 1GB) {
        ([math]::Round(($size) / 1GB, $decimalPlaces)).toString() + " GB"
    } elseif ($size -ge 1MB) {
        ([math]::Round(($size) / 1MB, 0)).toString() + " MB"
    } elseif ($size -ge 1KB) {
        ([math]::Round(($size) / 1KB, 0)).toString() + " KB"
    } else {
        $size.toString() + " bytes"
    }
}

# PC / Login data
$pcInfo = (Get-WmiObject -Class Win32_ComputerSystem)
$pcName = $pcInfo.Name
$userName = $pcInfo.UserName.Split("\")[-1]

# Profile data
$profileArray = Get-Childitem -Path C:\users\
$numUsers = $profileArray.Length

# Create user Vs non-user profile Arrays
$userArray = New-Object System.Collections.ArrayList
$nonUserArray = New-Object System.Collections.ArrayList
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
$displayUser = Format-Size $userProfileSize -decimalPlaces 2
$displayAllUsers = Format-Size $allUserProfileSize
$displayOneDrive = Format-Size $oneDriveSize -decimalPlaces 2

# Output Results
Write-Output "There are $numUsers user profiles on PC '$pcName' totalling $displayAllUsers user data."
Write-Output "The current logged in user is $userName, with a profile size of $displayUser."
if ($oneDriveExists) { Write-Output "$userName has a OneDrive folder, which is $displayOneDrive." }
