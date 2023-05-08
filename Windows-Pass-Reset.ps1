 # Set the number of days before password expiration to check
$daysBeforeExpiration = 10

# Get the current user's password expiration date
$passwordExpiration = (Get-LocalUser $env:USERNAME).PasswordExpires

# Calculate the number of days until the password expires
$daysUntilExpiration = ($passwordExpiration - (Get-Date)).Days

# Check if the password is going to expire in the next $daysBeforeExpiration days
Function CheckAndChangePass() {
    if ($daysUntilExpiration -le $daysBeforeExpiration) {
        # Generate a random password
        $newPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 14 | ForEach-Object { [char]$_ })
        $Date = Get-Date -Format "yyyy/MM/dd"
        $IpAddress = (get-netadapter | get-netipaddress | ? addressfamily -eq 'IPv4').ipaddress
        New-SECSecret -SecretString $newPassword -Description "New Administrator Password for Windows Machine" -Name $IpAddress-$Date 
        # Set the new password
        $user = [ADSI]("WinNT://./$env:USERNAME,user")
        $user.SetPassword($newPassword)

        # Output the new password
        Write-Output "New password set: $newPassword"
    } else {
        Write-Output "Password does not need to be changed."
            }
}

CheckAndChangePass  
