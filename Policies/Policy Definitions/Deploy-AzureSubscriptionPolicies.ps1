 <#

.SYNOPSIS
Deploys a set of Azure Resource Policy JSON template to Azure.

.DESCRIPTION
See synopsis. Ensure that all the JSON files are in the same folder as the script.

.EXAMPLE
.\Deploy-AzureSubscriptionPolicies.ps1 -SubscriptionName "Contoso.Lab"

.NOTES
Authored by Wahid Saleemi (Microsoft Services).

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$SubscriptionName = "Contoso.Lab"
)

Select-AzureRmSubscription -SubscriptionName $SubscriptionName
$subId = (Get-AzureRmSubscription -SubscriptionName $SubscriptionName).SubscriptionId

$policy = New-AzureRmPolicyDefinition -Name tags-notags -Description "Policy to enforce tags" -Policy "./pol-append-tags-notags.json"
New-AzureRmPolicyAssignment -Name tags-notags -PolicyDefinition $policy -Scope /subscriptions/$subId

$policy = New-AzureRmPolicyDefinition -Name tags-owner -Description "Policy to append owner tag if missing." -Policy "./pol-append-tags-owner.json"
New-AzureRmPolicyAssignment -Name tags-owner -PolicyDefinition $policy -Scope /subscriptions/$subId

$policy = New-AzureRmPolicyDefinition -Name tags-env -Description "Policy to append environment tag if missing." -Policy "./pol-append-tags-env.json"
New-AzureRmPolicyAssignment -Name tags-env -PolicyDefinition $policy -Scope /subscriptions/$subId

$policy = New-AzureRmPolicyDefinition -Name tags-costcenter -Description "Policy to append costCenter tag if missing." -Policy "./pol-append-tags-costcenter.json"
New-AzureRmPolicyAssignment -Name tags-costcenter -PolicyDefinition $policy -Scope /subscriptions/$subId

$policy = New-AzureRmPolicyDefinition -Name location-noneastus2 -Description "Policy to deny using locations other than US East 2." -Policy "./pol-deny-location-noneastus2.json"
New-AzureRmPolicyAssignment -Name location-noneastus2 -PolicyDefinition $policy -Scope /subscriptions/$subId

$policy = New-AzureRmPolicyDefinition -Name vnet-write -Description "Policy to deny creation and modification of vnets." -Policy "./pol-deny-vnet-write.json"
New-AzureRmPolicyAssignment -Name vnet-write -PolicyDefinition $policy -Scope /subscriptions/$subId

