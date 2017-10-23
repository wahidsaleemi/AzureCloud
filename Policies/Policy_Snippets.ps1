

#Make sure you're logged in via Login-AzureRmAccount

#Set the subscription
$subscriptionName = "Contoso.Lab"
$subId = (Get-AzureRmSubscription -SubscriptionName $subscriptionName).SubscriptionId

#List all of the ASSIGNED policies (there are effective)
Get-AzureRmPolicyAssignment | select Name

#List all of the DEFINED policies (these may not be in effect)
Get-AzureRmPolicyDefinition | Select Name

#Un-assign a policy (make it non-effective)
Remove-AzureRmPolicyAssignment -Name "the-name" -Scope /subscriptions/$subId

#Completely delete the policy
Remove-AzureRmPolicyDefinition -Name "the-name" -Force

#View the policy rule (what is it doing)
Get-AzureRmPolicyDefinition -Name "the-name" | select -ExpandProperty Properties | select -ExpandProperty policyRule

