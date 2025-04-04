# This will check the current version of windows and update only if it is windows version 10.0.22631 (23H2)
# This will install KB 5053602

$targetVersion = "10.0.22631"
$targetKB = "5053602"
$downloadURI = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/cf6a62b9-4c7f-4703-aeb7-9ef0df5f29f1/public/windows11.0-kb5053602-x64_c1dc9c521f329ff91d92ab59713cb0f01959fa4e.msu"

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
        DISM /online /Add-Package /PackagePath:C:\Temp\windowsUpdate.msu /NoRestart
        Remove-Item C:\Temp\windowsUpdate.msu
        Write-Output "`n`nUpdate Completed:"
        Start-Sleep 90
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
