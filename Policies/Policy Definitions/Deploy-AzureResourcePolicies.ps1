 <#

.SYNOPSIS
Deploys a set of Azure Resource Policy JSON template to Azure.

.DESCRIPTION
See synopsis. Ensure that all the JSON files are in the same folder as the script.

.EXAMPLE
.\Deploy-AzureSubscriptionPolicies.ps1 -SubscriptionName "Contoso.Lab" -ResourceGroupName "rg-ContosoLab-core"

.NOTES
Authored by Wahid Saleemi (Microsoft Services).

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$SubscriptionName = "Contoso.Lab",
    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName
)

$error.clear()
try 
    {
        Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Stop
    }
catch 
    {
        if($Error[0].Exception.Message.Contains("does not exist"))
        {
            Write-Host "Can't find that resource group name in this subscription. Use Get-AzureRmResourceGroup to list the names in $SubscriptionName." -ForegroundColor Yellow
        }
    }

$resourcegroupId = (Get-AzureRmResourceGroup -Name $ResourceGroupName).ResourceId

$policy = New-AzureRmPolicyDefinition -Name publicip-noip -Description "Policy to deny Public IP creation." -Policy "./pol-deny-publicip-noip.json"
New-AzureRmPolicyAssignment -Name publicip-noip -PolicyDefinition $policy -Scope $resourcegroupId
