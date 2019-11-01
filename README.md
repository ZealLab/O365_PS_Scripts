# O365_PS_Scripts

This is a collection of scripts to preform administrative tasks in Office 365 for one or multiple accounts.

First run the o365.ps1 script, it will prompt you for information of the o365 administrative account.

Information requested:
Administrator Acccount
Password
Default Domain to use
Format of the email address naming convention the company uses.

Once complete it will write a config file to C:\Scripts\Config that holds the account information locally.
This config file is used by other scripts in this collection to make modifications to user accounts ect.

It is best to store the o365.ps1 in a PATH directory such as C:\Windows\System32\ so that you can use 
PowerShell's Intellisense to autocomplete the account parameter.

NO SPACES OR SPECIAL CHARACTERS except '_' can be used in the account name parameter.
