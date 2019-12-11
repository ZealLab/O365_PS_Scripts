﻿<#
.SYNOPSIS
  Office 365 Forward mail to user
.DESCRIPTION
  This script will forward a Office 365 account to a user
.PARAMETER
  None at this time
.INPUTS
  Requires msol session generated by the o365.ps1 script
.OUTPUTS
  None at this time
.NOTES
  Version:        1.0
  Author:         Ryan Bowen
  Company:        MedX Solutions
  Creation Date:  12/11/2019
  Modified Date:  
  Purpose/Change:
  
.EXAMPLE
  ".\o365ForwardMailToUser.ps1"
#>

Write-Host "
       Users
-------------------"
(Get-MsolUser -All | Where {$_.isLicensed -eq $true}).UserPrincipalName | Sort
Write-Host "-------------------
"
$source = Read-Host "Account to be forwarded from"
Write-Host "
Current Forwarding
-------------------"
(Get-Mailbox -Identity $source).ForwardingSmtpAddress
Write-Host "-------------------
"
$target = Read-Host "Account to be forwarded to"
Set-Mailbox -Identity $source -DeliverToMailboxAndForward $true -ForwardingSmtpAddress $target
Write-Host "
Added $source to forward to $target"

Remove-Variable source,target