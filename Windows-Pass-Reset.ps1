Function Get-RandomAlphanumericString
{
    [CmdletBinding()]
    Param ([int] $length = 14)
 
    Begin {}
 
    Process
    {
        $NewPassword = (-join ((33..126) | Get-Random -Count 14 | % {[char]$_})
)
        return $NewPassword
    }
}




$NewPass = Get-RandomAlphanumericString
Write-Output $NewPass
#$NewPassword = GET-Temppassword -length 14 -sourcedata $ascii

$SecurePass = ConvertTo-SecureString $NewPass -AsPlainText -Force
Write-Output $SecurePass

Set-LocalUser -Name Administrator -Password $SecurePass
ConvertFrom-SecureString -SecureString $SecurePass
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass))
$Date = Get-Date -Format "yyyy/MM/dd"
$IpAddress = (get-netadapter | get-netipaddress | ? addressfamily -eq 'IPv4').ipaddress
New-SECSecret -SecretString $SecurePass -Description "New Administrator Password for Windows Machine" -Name $IpAddress-$Date 
