## Create an array of users (SID/UserHive/Username) and a list of loaded and unloaded hives
$SIDPrefix = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$UserArray =  Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' |
    Where-Object    {$_.PSChildName -match $SIDPrefix} |
    Select-Object   @{name="SID";expression={$_.PSChildName}},
                    @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}},
                    @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
$LoadedHives = Get-ChildItem Registry::HKEY_USERS -ErrorAction SilentlyContinue | 
    Where-Object {$_.PSChildname -match $SIDPrefix} | 
    Select-Object @{name="SID";expression={$_.PSChildName}}
$UnloadedHives = Compare-Object $UserArray.SID $LoadedHives.SID | Select-Object @{name="SID";expression={$_.InputObject}}

function HideIcon {
    param (
        [string] $SID
    )
    Write-Output "user SID is $SID"
}


## Below script will remove spotlight key and add "hidden" attribute to spotlight icon - this will work for current user ONLY
##TODO: change below script into a method and use a for-loop for each user in hive
##NB: ensure Unloaded Hives have garbage collection and registry unloaded after modification
$spotlightPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\"
$spotlightKey = "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}"
$iconPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\"
$iconKey = $spotlightKey

$spotlightKeyExists = Test-Path $spotlightPath$spotlightKey
$iconPathExists = Test-Path $iconPath

Write-Output "Does spotlight key exist?: " $spotlightKeyExists
Write-Output "Does icon path exist?: " $iconPathExists

if($spotlightKeyExists){
        Write-Output "Spotlight key DOES exist.... removing..."
        Remove-Item $spotlightPath$spotlightKey
    } else {
        Write-Output "Spotlight key does NOT exist..."
}

if(!$iconPathExists){
        Write-Output "Icon path does not exist... creating...."
        New-Item -Path $iconPath -Force | Out-Null
    } else {
        Write-Output "Icon path already exists..."
}

New-ItemProperty -Path $iconPath -Name $iconKey -Value "1" -PropertyType "DWORD" -Force | Out-Null

foreach ($user in $UserArray) {
    $name = $user.Username
    if ($user.SID -in $LoadedHives.SID) {
        Write-Output "$name is loaded"
        HideIcon($user.SID)
    } else {
        Write-Output "$name is NOT loaded"
        reg load HKU\$($user.SID) $($user.UserHive) | Out-Null
        Write-Output "$name is NOW loaded"
        HideIcon($user.SID)
        [gc]::Collect()
        reg unload HKU\$($user.SID) | Out-Null
    }
}


## Below is output for testing purposes only
Write-Output "`n`n`nUser Array:" $UserArray
Write-Output "`n`nLoaded Hives:" $LoadedHives
Write-Output "`n`nUnloaded Hives:" $UnloadedHives