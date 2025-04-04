# This will check the current version of windows and update only if it is windows version 10.0.26100 (24H2)
# This will install KB 5053598

$targetVersion = "10.0.26100"
$targetKB = "5053598"
$downloadURI = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4807b0b1-6c5a-4a70-ab45-b378235fb9d6/public/windows11.0-kb5053598-x64_6cb3ffc5c4d652793dc71705248426eecdacdfd0.msu"

$winVer = Get-ComputerInfo | Select-Object OSName, OSVersion
$osVer = $winVer.OSName
$osNum = $winVer.OSVersion
$latestKB = (Get-HotFix | Sort-Object -Property InstalledOn)[-1].HotFixID
Write-Output "PC is running $osVer"
Write-Output "Windows is version $osNum"
Write-Output "Latest KB is $latestKB"

$safeToUpdate = ($osNum -eq $targetVersion)

if ($safeToUpdate) {
    if ($latestKB -eq $targetKB) {
        Write-Output "PC is already up to date on KB $targetKB"
        Write-Output "Update cancelled"
    } else {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-Webrequest -Uri $downloadURI -OutFile "C:\Temp\windowsUpdate.msu"
        DISM /online /Add-Package /PackagePath:C:\Temp\windowsUpdate.msu /NoRestart /quiet
        Remove-Item C:\Temp\windowsUpdate.msu
        Write-Output "`n`nUpdate Completed:"
        $winVer = Get-ComputerInfo | Select-Object OSName, OSVersion
        $osVer = $winVer.OSName
        $osNum = $winVer.OSVersion
        $latestKB = (Get-HotFix | Sort-Object -Property InstalledOn)[-1].HotFixID
        Write-Output "PC is running $osVer"
        Write-Output "Windows is version $osNum"
        Write-Output "Latest KB is $latestKB"
    }
} else {
    Write-Output "Update cancelled - NOT SAFE TO UPDATE"
}
