## Create an array of users (SID/UserHive/Username) and a list of loaded and unloaded hives
$SIDPrefix = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$UserArray = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' |
    Where-Object    {$_.PSChildName -match $SIDPrefix} |
    Select-Object   @{name="SID";expression={$_.PSChildName}},
                    @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}},
                    @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
$LoadedHives = Get-ChildItem Registry::HKEY_USERS -ErrorAction SilentlyContinue | 
    Where-Object {$_.PSChildname -match $SIDPrefix} | 
    Select-Object @{name="SID";expression={$_.PSChildName}}
$UnloadedHives = Compare-Object $UserArray.SID $LoadedHives.SID | Select-Object @{name="SID";expression={$_.InputObject}}

## Function to list the loaded and unloaded hives, by username
function ListHives {
    Write-Output "`nLoaded Hives:"
    foreach($user in $UserArray){
        if ($LoadedHives.SID -contains $user.SID){
            Write-Output $user.Username
        }
    }
    Write-Output "`nUnloaded Hives:"
    foreach($user in $UserArray){
        if ($UnloadedHives.SID -contains $user.SID){
            Write-Output $user.Username
        }
    }
}

## Function to remove "Learn more about this image" icon
function HideIcon {
    param (
        [string] $SID
    )
    $spotlightPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\"
    $spotlightKey = "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}"
    $iconPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\"
    $iconKey = $spotlightKey

    $spotlightKeyExists = Test-Path Registry::HKEY_USERS\$SID\$spotlightPath$spotlightKey
    $iconPathExists = Test-Path Registry::HKEY_USERS\$SID\$iconPath
    $iconKeyValueExists = ($null -ne (Get-ItemProperty -Path "Registry::HKEY_USERS\$SID\$iconPath" -ErrorAction SilentlyContinue).$iconKey)

    Write-Output "user SID is $SID"
    
    if($spotlightKeyExists){
        Write-Output "Spotlight key DOES exist.... removing..."
        Remove-Item Registry::HKEY_USERS\$SID\$spotlightPath$spotlightKey
    } else {
        Write-Output "Spotlight key does NOT exist... no need to remove..."
    }

    if(!$iconPathExists){
        Write-Output "Icon path does not exist... creating...."
        New-Item -Path Registry::HKEY_USERS\$SID\$iconPath -Force | Out-Null
    } else {
        Write-Output "Icon path already exists..."
    }

    if ($iconKeyValueExists){
        if ((Get-ItemProperty -Path Registry::HKEY_USERS\$SID\$iconPath).$iconKey -eq 1){
        Write-Output "Icon is already hidden"
        } else {
            New-ItemProperty -Path Registry::HKEY_USERS\$SID\$iconPath -Name $iconKey -Value "1" -PropertyType "DWORD" -Force | Out-Null
            Write-Output "Changing icon key value to `"hidden`""
        }
    } else {
        New-ItemProperty -Path Registry::HKEY_USERS\$SID\$iconPath -Name $iconKey -Value "1" -PropertyType "DWORD" -Force | Out-Null
        Write-Output "Adding `"hidden`" icon key"
    }
}

## BEFORE script is run...
ListHives

<#  
    For loop goes through each user in user array. If hive is loaded will run function HideIcon.
    If hive is not loaded will check if user data exists on PC. This may not be the case if user folder
    has been deleted or not created. If data exists will load hive, run function HideIcon then unload hive.
#> 
foreach ($user in $UserArray) {
    $name = $user.Username
    $userExists = Test-Path $user.UserHive
    Write-Output "`nProcessing user: $name"
    if ($user.SID -in $LoadedHives.SID) {
        HideIcon($user.SID)
    } else {
        if ($userExists) {
            reg load HKU\$($user.SID) $($user.UserHive) | Out-Null            
            HideIcon($user.SID)
            [gc]::Collect()
            reg unload HKU\$($user.SID) | Out-Null            
        } else {
            "User data does not exist... ignoring this user."
        }
    }
}

## AFTER script is run...
Write-Output "`n`nScript has completed.`n"
ListHives
Write-Output $UserArray
