Write-Host "
       Users
-------------------"
(Get-MsolUser -All).UserPrincipalName | Sort
Write-Host "-------------------
"
$user = Read-Host -Prompt 'User to remove from distribution lists: '
$groups = Get-DistributionGroup
ForEach ($group in $groups)
    {
    $names = (Get-DistributionGroupMember -Identity $group.Name).Name
    if ($user -in $names)
        {
        Remove-DistributionGroupMember -Identity $group.DisplayName -Member $user
        Write-Host "Removed user from "$group.DisplayName
        }
    }