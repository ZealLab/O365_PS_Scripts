﻿<#
.SYNOPSIS
  Office 365 Create User
.DESCRIPTION
  This script will create a new o365 user using the session connected by o365.ps1 script.
  The Account variable is defined in the o365.ps1 script and should stay in the PSSession for this script to use
.PARAMETER
  None at this time
.INPUTS
  Requires the Account variable that is passed by the o365.ps1 script.
  Requires the o365 config file. This is generated by the o365.ps1 script located at C:\Scripts\Config\o365.psd1
.OUTPUTS
  None at this time
.NOTES
  Version:        1.0
  Author:         Ryan Bowen
  Company:        MedX Solutions
  Creation Date:  09/12/2019
  Modified Date:  11/01/2019
  Purpose/Change: Added description, Added random password generator
  
.EXAMPLE
  ".\o365CreateUser.ps1"
#>

function New-Password 
{
    $c = $null
    for ($i = 1; $i -lt 15; $i++) 
    {
        $a = Get-Random -Minimum 1 -Maximum 4 
        switch ($a) 
        {
            1 {$b = Get-Random -Minimum 48 -Maximum 58}
            2 {$b = Get-Random -Minimum 65 -Maximum 91}
            3 {$b = Get-Random -Minimum 97 -Maximum 123}
        }
        [string]$c += [char]$b
    }
    $c = $c + "!"
    $c
}

[int]$int = 0
Write-Host "
Licenses
----------------
"
ForEach($sku in Get-MsolAccountSku)
    {
    Write-Host $sku.AccountSkuId " |  Licenses Available: "($sku.ActiveUnits - $sku.ConsumedUnits)
    [int]$int = [int]$int + ([int]$sku.ActiveUnits - [int]$sku.ConsumedUnits)
    }
Write-Host "
----------------
"
if ([int]$int -eq 0)
    {
    Write-Host "There are no Office 365 licenses available. Here is a list of currently licensed accounts, do you see any that we could deactivate? If not would you like to add an additional license?
    "
    (Get-MsolUser -All | where {$_.isLicensed -eq $true}).UserPrincipalName
    exit
    }
$cfg = 'C:\Scripts\Config'
Import-LocalizedData -BindingVariable "Config" -BaseDirectory $cfg -FileName o365.psd1
$license = Read-Host "Enter the license to assign user above"
$first = Read-Host "Enter the First Name of the user"
$last = Read-Host "Enter the Last Name of the user"
$phone = Read-Host "Phone number (If any)"
$department = Read-Host "Department (If any)"
$domain = "Domain_$Account"
$format = "Format_$Account"

if ($Config.$format -eq 1)
    {
    $user = $first[0]+$last+"@"+$Config.$domain
    }
elseif ($Config.$format -eq 2)
    {
    $user = "$first.$last"+"@"+$Config.$domain
    }
elseif ($Config.$format -eq 3)
    {
    $user = $last+$first[0]+"@"+$Config.$domain
    }
elseif ($Config.$format -eq 4)
    {
    $user = $first+"@"+$Config.$domain
    }
elseif ($Config.$format -eq 5)
    {
    $user = $first+$last[0]+"@"+$Config.$domain
    }
else
    {
    Write-Warning "Format incorrect Config needs debugging"
    exit
    }
$pw = New-Password
if ($phone -and $department)
    {
        New-MsolUser -DisplayName "$first $last" -FirstName $first -LastName $last -UserPrincipalName $user -UsageLocation US -LicenseAssignment $license -PhoneNumber $phone -Password $pw -Department $department -Verbose
        Write-Host $user
    }
elseif ($phone)
    {
        New-MsolUser -DisplayName "$first $last" -FirstName $first -LastName $last -UserPrincipalName $user -UsageLocation US -LicenseAssignment $license -PhoneNumber $phone -Password $pw -Verbose
        Write-Host $user
    }
elseif ($department)
    {
        New-MsolUser -DisplayName "$first $last" -FirstName $first -LastName $last -UserPrincipalName $user -UsageLocation US -LicenseAssignment $license -Password $pw -Department $department -Verbose
        Write-Host $user
    }
else
    {
        New-MsolUser -DisplayName "$first $last" -FirstName $first -LastName $last -UserPrincipalName $user -UsageLocation US -LicenseAssignment $license -Password $pw -Verbose
        Write-Host $user
    }
Write-Host "
Distribution Groups
-------------------"
(Get-DistributionGroup).DisplayName | Sort
Write-Host "-------------------
"
$group = Read-Host "Distribution group to add user to (if none leave blank)"
While ($group)
    {
    Add-DistributionGroupMember -Identity $group -Member $user -Confirm:$false
    Write-Host "User $user added to the $group distribution group."
    $group = Read-Host "Additional group to add user to (if none leave blank)"
    }
Write-Host "
I created the following E-Mail Account
UserName: $user
Password: $pw
"
# Not working yet.
#Added User to the Following Distribution list
#$(ForEach ($group in (Get-DistributionGroup)){Write-Host $group.Name | Where (Get-DistributionGroupMember -Identity $group.Name).Name.tostring -match "Jason.McFarland"})


Remove-Variable first,last,user,license,phone,pw,department,domain,group,int