<#
.SYNOPSIS
  Office 365 Connector
.DESCRIPTION
  This script will connect to managed Office 365 account
.PARAMETER
  Should currently be maintined in the ValidateSet by the User
.INPUTS
  None at this time
.OUTPUTS
  Config file created and maintained at C:\Scripts\Config\o365.psd1
  Active o365 session
.NOTES
  Version:        1.1
  Author:         Ryan Bowen
  Company:        
  Creation Date:  09/12/2019
  Modified Date:  10/30/2019
  Purpose/Change: Added configuration file to hold account credentials
  
.EXAMPLE
  ".\o365.ps1 -Account 'Test_Account_Name'"
#>
Param(
[Parameter(Mandatory=$true)]
[ValidateSet(
# List of account names (No Spaces " ")
"Test_Account_Name",
"Other_Account_Name"
)]
[String[]]$Account
)

Import-Module -Name AzureAD
Import-Module -Name MSOnline
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

$cfg = 'C:\Scripts\Config'
if ($(Test-Path -Path 'C:\Scripts\') -eq ($false))
    {
    New-Item -Path 'C:\' -Name 'Scripts' -ItemType Directory
    }
if ($(Test-Path -Path 'C:\Scripts\Config\') -eq ($false))
    {
    New-Item -Path 'C:\Scripts\' -Name 'Config' -ItemType Directory
    }
if ($(Test-Path -Path $cfg\o365.psd1) -eq ($false))
    {

    [string]$user = $(Read-Host -Prompt "Please enter the Administrator email account")
    $password = $(Read-Host -Prompt "Please enter the Password for $user" -AsSecureString | ConvertFrom-SecureString)
    $admin = "Admin_$Account"
    $pwd = "Password_$Account"
    $dom = "Domain_$Account"
    $form = "Format_$Account"
    [string]$domain = $(Read-Host -Prompt "Please enter the default domain for the account(eg. test.com)")
    [int]$format = $(Read-Host -Prompt "Please select the default email format for user (First Last)
    [1] flast@$domain
    [2] first.last@$domain
    [3] lastf@$domain
    [4] first@$domain
    ")
    While ($format -eq $null)
    {
    [int]$format = $(Read-Host -Prompt "Please select the default email format for user (First Last)
    [1] flast@$domain
    [2] first.last@$domain
    [3] lastf@$domain
    [4] first@$domain
    ")
    }
@"
@{
$admin = "$user"
$pwd = "$password"
$dom = "$domain"
$form = "$format"
}
"@ | Out-File -FilePath $cfg\o365.psd1
    }
Import-LocalizedData -BindingVariable "Config" -BaseDirectory $cfg -FileName o365.psd1
$admin = "Admin_$Account"
$pwd = "Password_$Account"
$dom = "Domain_$Account"
$form = "Format_$Account"

if ($Config.$admin -eq $null)
    {
    [string]$user = $(Read-Host -Prompt "Please enter the Administrator email account")
    $password = $(Read-Host -Prompt "Please enter the Password for $admin" -AsSecureString | ConvertFrom-SecureString)
    [string]$domain = $(Read-Host -Prompt "Please enter the default domain for the account(eg. test.com)")
    [int]$format = $(Read-Host -Prompt "Please select the default email format for user (First Last)
    [1] flast@$domain
    [2] first.last@$domain
    [3] lastf@$domain
    [4] first@$domain
    ")

@"
@{
$admin = "$user"
$pwd = "$password"
$dom = "$domain"
$form = "$format"
}
"@ | Out-File -FilePath $cfg\o365.psd1 -Append
    Import-LocalizedData -BindingVariable "Config" -BaseDirectory $cfg -FileName o365.psd1
    }
$password = $Config.$pwd | ConvertTo-SecureString
$user = $Config.$admin
$cred = New-Object System.Management.Automation.PSCredential ($user, $password)

Connect-AzureAD -Credential $cred
Connect-MsolService -Credential $cred
Get-PSSession | Remove-PSSession
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
# Exchange Uri https://outlook.office365.com/powershell-liveid/
# Compliance Uri https://ps.compliance.protection.outlook.com/powershell-liveid/
Import-PSSession $Session -DisableNameChecking
Set-Variable -Name Account -Value $Account -Scope Global
Remove-Variable admin,password,user,Session,cfg