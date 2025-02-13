if ((Get-ItemPropertyValue -Path Registry::HKEY_USERS\bnmbm -Name $iconKey) -eq 1) {
    Write-Output "Icon is already hidden"
} else {
    Write-Output "Adding `"hidden`" property to icon"
}


$value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'NullSessionShares'

if ([string]::IsNullOrWhiteSpace($value)) {
    Write-Output "SUCCESS"
} else {
    Write-Output "FAILED"
}

$test = (Get-ItemProperty -Path "HKLM\SYSTEM\sssss").sdada

if ($null -eq $test) {Write-Output "THIS IS NULL"}