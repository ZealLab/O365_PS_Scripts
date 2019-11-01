$groups = Get-DistributionGroup
ForEach ($group in $groups)
    {
    Write-Host " "
    Write-Host $group.DisplayName
    Write-Host '-------------------------'
    (Get-DistributionGroupMember -Identity $group.Name).Name
    }