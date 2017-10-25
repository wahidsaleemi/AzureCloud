

Login-AzureRmAccount -TenantId ""
$subscriptionId = ""
$folder = ".\Templates\PolicySet-Storage"
Set-Location $folder

#region PolicyDefinitions
#Audit Managed Disks
$params1 = @{
Name = "audit-managedDisks"
DisplayName = "Storage: Audit VMs that do not use managed disks"
Description = "This policy audits VMs that do not use managed disks."
Metadata = "Storage Security"
Policy = "pol-storage-audit-NoManagedDisks.json"
}

#Deny No Blob Encryption
$params2 = @{
Name = "deny-NoBlobEncryption"
DisplayName = "Storage: Ensure Blob Encryption is on for Storage Accounts."
Description = "Deny creation of Storage Accounts if Blob Encryption is not on."
Metadata = "Storage Security"
Policy = "pol-storage-deny-NoBlobEncryption.json"
}

#Deny No File Encryption
$params3 = @{
Name = "deny-NoFileEncryption"
DisplayName = "Storage: Ensure File Encryption is on for Storage Accounts."
Description = "Deny creation of Storage Accounts if File Encryption is not on."
Metadata = "Storage Security"
Policy = "pol-storage-deny-NoFileEncyption.json"
}

#Deny No "HTTPS Only"
$params4 = @{
Name = "deny-NoHttpsOnly"
DisplayName = "Storage: Ensure https traffic only for storage account"
Description = "Deny creation of Storage Accounts if httpsOnly flag is not set."
Metadata = "Storage Security"
Policy = "pol-storage-deny-NoHttpsOnly.json"
}

#endregion

#region Create PolicySet Definition
$policyDefinitionIds = @()
$allParams = @($params1,$params2, $params3, $params4)
foreach ($params in $allParams)
    {
    Write-Host "Name: $(($params).Name)"
    $definition = New-AzureRmPolicyDefinition -Name $($params).Name `
                -DisplayName ($params).DisplayName `
                -Description ($params).Description `
                -Policy "$folder\$(($params).Policy)" `
                -Mode All
    $policyDefinitionIds += $definition.PolicyDefinitionId
    }

#Create an array with list of objects representing policy definition id's
$Target=@()
$policyDefinitionIds = @()
$allParams | 
    ForEach-Object {
        $policyDefinitionId = (Get-AzureRmPolicyDefinition -Name $_.Name | select -ExpandProperty PolicyDefinitionId)
        $TargetObject = New-Object PSObject –Property @{policyDefinitionId=$policyDefinitionId}
        $Target +=  $TargetObject
    }
$policySetDefinition = $target | ConvertTo-Json
#endregion

#region Define & Assign PolicySet
#Define the policy set
$policySetParams = @{
Name = "policySet-Storage"
DisplayName = "A set of Storage Policies to enhance security."
Description = "This initiative contains several Storage Policies to be applied at the subscription level."
PolicyDefinition = $policySetDefinition
}
$policySet =  New-AzureRmPolicySetDefinition @policySetParams -Verbose
#$policySet = Get-AzureRmPolicySetDefinition -Name $policySetParams.Name

$ExcludedResourceGroup1 = Get-AzureRmResourceGroup -Name "rg-aad"
$ExcludedResourceGroup2 = Get-AzureRmResourceGroup -Name "securitydata"
$sku = @{
name="A1"
tier="Standard"
}

$policyAssignmentParams = @{
Name = "StoragePolicySetAssignment"
DisplayName = "Storage Policy Set"
Description = "This initiative contains several Storage Policies to be applied at the subscription level."
PolicySetDefinition = $policySet
Scope = "/subscriptions/$subscriptionId"
NotScope = $ExcludedResourceGroup1.ResourceId, $ExcludedResourceGroup2.ResourceId
Sku = $sku
}
$policySetAssignment = New-AzureRmPolicyAssignment @policyAssignmentParams
#endregion

#Remove-AzureRmPolicyAssignment -Name $policyAssignmentParams.Name -Scope $policyAssignmentParams.Scope