<#
    This Script is designed to loop through a CSV list of users and check their mailbox setup for delegation, SEND AS and
    SEND ON BEHALF permissions. Optionally, if the bottom foreach loop is uncommented, will also check if these users are included
    in Outlook's global address list.

    This script is useful when a client provides a list of users no longer with the company, wanting to check the delegation and
    SEND AS status of their malbox/es. It can also be used for any list of users exported through the exchange admin portal.

    The script assumes that the CSV has a column titled PrimarySmtpAddress which is default when exporting users in the admin portal.
    The script assumes that this csv is titled "users.csv" and is stored in C:\temp
#>


# Check if the ExchangeOnlineManagement module is installed
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    # Install the module if it's not installed
    Write-Output "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
}


# Get credentials for login to 365 PowerShell
Connect-ExchangeOnline
# Copy user data into table with required field "PrimarySmtpAddress" (email address) saved in C:\temp as "users.csv"
$UserArray = Import-Csv -Path "C:\temp\users.csv"
Write-Output ($UserArray | Format-Table)
($UserArray | Format-Table) | Out-File C:\temp\CsvOutput.txt

# Function to check a mailbox for Send / Full Access / Send on Behalf
Function Check-MailboxDelegation {
    param (
        [string] $mailbox
    )

    # Check if mailbox exists
    $userExists = Get-EXOCasMailbox -Properties PrimarySmtpAddress | Where-Object {$_.PrimarySmtpAddress -eq "$mailbox"}

    # If mailbox does not exist, state it does not exist, else check for full access / send as / send on behalf permissions
    if ($null -eq $userExists) {
        Add-Content -Path "C:\temp\CsvOutput.txt" -Value "$mailbox does not exist"
        Write-Output "$mailbox does not exist"
    } else {
        # Check delegate access
        $fullAccess = Get-MailboxPermission -Identity "$mailbox" | Where-Object { $_.AccessRights -eq "FullAccess" }
        if ($null -ne $fullAccess) {
            $user = $fullAccess.User
            Write-Output "$user has delegate access to $mailbox"
            Add-Content -Path "C:\temp\CsvOutput.txt" -Value "$user has delegate access to $mailbox"
        }
        # Check SEND AS permisions
        $sendAs = Get-EXORecipientPermission -Identity "$mailbox" | Where-Object { $_.AccessRights -eq "SendAs" -and $_.Trustee -ne "NT AUTHORITY\SELF"}
        if ($null -ne $sendAs) {
            $trustee = $sendAs.Trustee
            Write-Output "$trustee can SEND AS $mailbox"
            Add-Content -Path "C:\temp\CsvOutput.txt" -Value "$trustee can SEND AS $mailbox"
        }
        # Check SEND ON BEHALF permissions
        $sendOnBehalf = Get-Mailbox -Identity "$mailbox" | Select-Object -ExpandProperty GrantSendOnBehalfTo
        if ($null -ne $sendOnBehalf) {
            Write-Output "$sendOnBehalf has access to SEND AS $mailbox"
            Add-Content -Path "C:\temp\CsvOutput.txt" -Value "$sendOnBehalf has access to SEND ON BEHALF of $mailbox"
        }
    }        
}

Function Check-AddressList {
    param(
        [string] $mailbox
    )

    # Check if mailbox exists
    $userExists = Get-EXOCasMailbox -Properties PrimarySmtpAddress | Where-Object {$_.PrimarySmtpAddress -eq "$mailbox"}

    if ($userExists) {
        # Check if user is hidden from address list
        $isUserHidden = (-Not(Get-Mailbox -Identity $mailbox).HiddenFromAddressListsEnabled)
        # If user is not hidden, output to console and txt file
        if ($isUserHidden) {
            Write-Output "$mailbox is NOT hidden from address lists"
            Add-Content -Path "C:\temp\CsvOutput.txt" -Value "$mailbox is NOT hidden from address lists"
        }
    }
}

foreach($i in $UserArray) {
    Check-MailboxDelegation $i.PrimarySmtpAddress
}


# The below text has been commented out - if uncommented will loop through users to determine which users are hidden from global address list

<#
Add-Content -Path "C:\temp\CsvOutput.txt" -Value "`n`n`nTHE FOLLOWING USERS ARE NOT HIDDEN FROM ADDRESS LIST:"

foreach($j in $UserArray) {
    Check-AddressList $j.PrimarySmtpAddress
}
#>