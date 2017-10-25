

Login-AzureRmAccount -TenantId ""
$subscriptionId = ""
$folder = ".\Policies\Policy Sets\PolicySet-VM"
Set-Location $folder
$policyDefinitionIds = @()


#region Get policyDefinitionIds for the Built-in policies
$builtInVMPolices = @(
"[Preview]: Monitor VM Vulnerabilities in Security Center",
"[Preview]: Monitor missing system updates in Security Center",
"[Preview]: Automatic provisioning of security monitoring agent",
"[Preview]: Monitor missing Endpoint Protection in Security Center",
"[Preview]: Monitor OS vulnerabilities in Security Center"
)

foreach ($builtInPolicy in $builtInVMPolices)
    {
    $id = Get-AzureRmPolicyDefinition | ? {$_.Properties.displayName -eq $builtInPolicy} | select -ExpandProperty PolicyDefinitionId
    $policyDefinitionIds += $id
    }
$policyDefinitionIds
#endregion

#region PolicyDefinitions

###Add custom policies

#Note: None yet.

#endregion

#Create an array with list of objects representing policy definition id's
$polSetArray=@()
$policyDefinitionIds | 
    ForEach-Object {
        $TargetObject = New-Object PSObject –Property @{policyDefinitionId=$_}
        $polSetArray +=  $TargetObject
    }


#Create the string/input for Policy Set Definition.
$policySetDefinition = $polSetArray | ConvertTo-Json -Depth 3
#endregion



#region Define & Assign PolicySet

$policySetParams = @{
Name = "policySet-VM"
DisplayName = "A set of VM Policies to enhance security."
Description = "This initiative contains several VM Policies to be applied at the subscription level."
PolicyDefinition = $policySetDefinition
Metadata = "{Category:`"VM Security`"}"
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
Name = "VMPolicySetAssignment"
DisplayName = "VM Policy Set"
Description = "This initiative contains several VM related policies to be applied at the subscription level."
PolicySetDefinition = $policySet
Scope = "/subscriptions/$subscriptionId"
NotScope = $ExcludedResourceGroup1.ResourceId, $ExcludedResourceGroup2.ResourceId
Sku = $sku
}
$policySetAssignment = New-AzureRmPolicyAssignment @policyAssignmentParams -Verbose
#endregion

#Remove-AzureRmPolicyAssignment -Name $policyAssignmentParams.Name -Scope $policyAssignmentParams.Scope