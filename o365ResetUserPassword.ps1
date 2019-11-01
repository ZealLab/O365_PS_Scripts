Write-Host "
       Users
-------------------"
(Get-MsolUser -All | Where {$_.isLicensed -eq $true}).UserPrincipalName | Sort
Write-Host "-------------------
"
$user = Read-Host "Email address to reset password: "
$password = Read-Host "Enter new password: "
Set-MsolUserPassword -UserPrincipalName $user -NewPassword $password