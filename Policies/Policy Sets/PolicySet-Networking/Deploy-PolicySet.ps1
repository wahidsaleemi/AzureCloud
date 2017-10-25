

Login-AzureRmAccount -TenantId ""
$subscriptionId = ""
$folder = ".\Policies\Policy Sets\PolicySet-Networking"
Set-Location $folder
$policyDefinitionIds = @()


#region Get policyDefinitionIds for the Built-in policies
$builtInNetworkPolices = @(
"[Preview]: Monitor permissive network access in Security Center",
"[Preview]: Monitor unprotected web application in Security Center",
"[Preview]: Monitor unprotected network endpoints in Security Center",
"[Preview]: Monitor possible network JIT access in Security Center"
)

foreach ($builtInPolicy in $builtInNetworkPolices)
    {
    $id = Get-AzureRmPolicyDefinition | ? {$_.Properties.displayName -eq $builtInPolicy} | select -ExpandProperty PolicyDefinitionId
    $policyDefinitionIds += $id
    }
$policyDefinitionIds
#endregion

#region PolicyDefinitions

###Audit Network Watcher
$customPolicyParams = @{
Name = "audit-networkWatcher"
DisplayName = "Network: Audit if Network Watcher is not enabled for region"
Description = "This policy audits if Network Watcher is not enabled for a selected region."
Metadata = "{Category:`"Network Security`"}"
Policy = "C:\Users\wasaleem\Documents\GitHub\AzureCloud\Policies\Policy Sets\PolicySet-Networking\pol-network-audit-networkWatcher.json"
Parameter = "C:\Users\wasaleem\Documents\GitHub\AzureCloud\Policies\Policy Sets\PolicySet-Networking\pol-network-audit-networkWatcher.parameters.json"
}

Write-Host "Name: $(($customPolicyParams).Name)"
$definition = New-AzureRmPolicyDefinition @customPolicyParams -Mode All
#Since this policy uses a parameter, we need to create a custom object with the parameter. We use nested objects.
$customObject = [PSCustomObject]@{ policyDefinitionId=$definition.policyDefinitionId;  parameters = 
                            [PSCustomObject]@{ location = 
                            [PSCustomObject]@{ value = "[parameters('location')]" }
                            }
                            }

#endregion

#Create an array with list of objects representing policy definition id's
$polSetArray=@()
$policyDefinitionIds | 
    ForEach-Object {
        $TargetObject = New-Object PSObject –Property @{policyDefinitionId=$_}
        $polSetArray +=  $TargetObject
    }
#Add the customObject
$polSetArray +=  $customObject

#Create the string/input for Policy Set Definition.
$policySetDefinition = $polSetArray | ConvertTo-Json -Depth 3
#endregion



#region Define & Assign PolicySet

<#
$policySetDefinition = @"
[
    {
        "policyDefinitionId":  "/providers/Microsoft.Authorization/policyDefinitions/44452482-524f-4bf4-b852-0bff7cc4a3ed"
    },
    {
        "policyDefinitionId":  "/providers/Microsoft.Authorization/policyDefinitions/201ea587-7c90-41c3-910f-c280ae01cfd6"
    },
    {
        "policyDefinitionId":  "/providers/Microsoft.Authorization/policyDefinitions/9daedab3-fb2d-461e-b861-71790eead4f6"
    },
    {
        "policyDefinitionId":  "/providers/Microsoft.Authorization/policyDefinitions/b0f33259-77d7-4c9e-aac6-3aabcfae693c"
    },
    {
        "policyDefinitionId":  "/subscriptions/c05079d4-ae7d-4186-ae74-5f4444129f26/providers/Microsoft.Authorization/policyDefinitions/audit-networkWatcher",
        "parameters": {
			"location": {
				"value": "[parameters('location')]"
			}
		}
    }
]
"@
#>

#Define the policy set, including the parameter file (required if any policies use parameters)
$PolicySetParameter = "c:\Users\wasaleem\Documents\GitHub\AzureCloud\Policies\Policy Sets\PolicySet-Networking\polset-Network.parameters.json"

$policySetParams = @{
Name = "policySet-Network"
DisplayName = "A set of Network Policies to enhance security."
Description = "This initiative contains several Network Policies to be applied at the subscription level."
PolicyDefinition = $policySetDefinition
Parameter = $PolicySetParameter
Metadata = "{Category:`"Network Security`"}"
}

$policySet =  New-AzureRmPolicySetDefinition @policySetParams -Verbose

#endregion

#Region Assign the policy
$ExcludedResourceGroup1 = Get-AzureRmResourceGroup -Name "rg-aad"
$ExcludedResourceGroup2 = Get-AzureRmResourceGroup -Name "securitydata"
$sku = @{
name="A1"
tier="Standard"
}

$policyAssignmentParams = @{
Name = "NetworkPolicySetAssignment"
DisplayName = "Network Policy Set"
Description = "This initiative contains several Network related policies to be applied at the subscription level."
PolicySetDefinition = $policySet
Scope = "/subscriptions/$subscriptionId"
NotScope = $ExcludedResourceGroup1.ResourceId, $ExcludedResourceGroup2.ResourceId
Sku = $sku
}
$policySetAssignment = New-AzureRmPolicyAssignment @policyAssignmentParams  -location "eastus"
#endregion

#Remove-AzureRmPolicyAssignment -Name $policyAssignmentParams.Name -Scope $policyAssignmentParams.Scope