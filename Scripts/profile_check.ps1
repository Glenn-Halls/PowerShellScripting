<#
    This script will pull information about user profiles on a target PC, to determine the size of the current user, and other users' profiles.
    It will also show the user's OneDrive folder size (if it exists) and the size taken up by any .PST files.
    This information is helpful prior to deployment of a replacement PC, to determine space requirements for data backup, or to help a user free
    up space on their PC if needed.
#>
 
Set-StrictMode -Version latest
 
Function Get-Size {
    # Get size of folder including subfolders with option to exclude OneDrive Folder.
    param (
        [string] $path,
        [boolean] $excludeOneDrive = $false,
        [boolean] $excludePst = $false
    ) 
        $size = ( Get-Childitem -Path "$path" -Force -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property "Length" -Sum )
 
        # Null check
        if ($null -eq $size) {
            return 0
        } else {
            $size.Sum
        }
}
 
Function Format-Size {
    # Transform size from [integer] bytes to [string] size for display to user, with optional decimal places if over 1GB.
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
$loginExists = ($null -ne $pcInfo.UserName)
$userName = if ($loginExists) {$pcInfo.UserName.Split("\")[-1]} else {"NO USER LOGGED ON"}
 
# Profile data
$profileArray = Get-Childitem -Path C:\Users\
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
$userProfileSize = if ($loginExists) {Get-Size "C:\Users\$userName"} else {0}
$nonUserProfileSize = 0
$nonUserHashTable = @{}
foreach($i in $nonUserArray) {
    $size = Get-Size "C:\users\$i"
    $nonUserProfileSize += $size
    $nonUserHashTable.Add($i, (Format-Size $size))
}
$allUserProfileSize = $userProfileSize + $nonUserProfileSize
 
# Check for user OneDrive Folder & measure size if it exists
$oneDriveExists = Test-Path -Path C:\Users\$userName\OneDrive
$oneDriveSize = if ($oneDriveExists) {
    ( Get-Size "C:\users\$userName\OneDrive" )
} else {0}
 
# Check for PST files and measure size if they exist
$pstScan = Get-Childitem -path C:\Users\$userName -Force -Include *.PST -Recurse -ErrorAction SilentlyContinue
$outlookExists = ($null -ne $pstScan)
$pstCount = if ($outlookExists) {$pstScan.Count} else {0}
$pstSize = if ($outlookExists) {
    ( $pstScan | Measure-Object -Property "Length" -Sum ).Sum
} else {0}
 
# Format display output
$displayUser = Format-Size $userProfileSize -decimalPlaces 2
$displayAllUsers = Format-Size $allUserProfileSize
$displayOneDrive = Format-Size $oneDriveSize -decimalPlaces 2
$displayPstSize = Format-Size $pstSize -decimalPlaces 2
$pstPlural = if ($pstSize -eq 1) {""} else {"s"}
$userPlural = if ($numUsers -eq 1) {""} else {"s"}
$userAreIs = if ($numUsers -eq 1) {"is"} else {"are"}
 
# Output Results
Write-Output "There $userAreIs $numUsers user profile$userPlural on PC '$pcName' totalling $displayAllUsers user data."
if ($loginExists) {Write-Output "The current logged in user is $userName, with a profile size of $displayUser."}
    else {
        Write-Output "No user is currently logged in to this PC, Pease try again when target user is logged on."
    }
if ($oneDriveExists) { Write-Output "$userName has a OneDrive folder, which is $displayOneDrive." }
if ($outlookExists) { Write-Output "$userName has $pstCount PST file$pstPlural, measuring $displayPstSize." }
if ($outlookExists) {
    Write-Output "`n$userName's PST file$pstPlural can be found in the location$pstPlural below:"
    forEach ($i in $pstScan) {
        Write-Output "$i"
    }
}
if ($null -ne $nonUserHashTable) {
    Write-Output "`nOther user profiles on this PC are as follows:"
    Write-Output $nonUserHashTable
}
