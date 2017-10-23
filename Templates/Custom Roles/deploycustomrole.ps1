
$subscriptionId = ""
$tempfile = "$env:TEMP\customrole.json"
$roledefinition = Get-Content -Path ".\role-encrypted-vm-contrib.json"
$objectId = "" #The user's object ID

#region Find the line for AssignableScopes
$roledefinition | 
      Foreach-Object { 
        $_ # send the current line to output
        if($_ -match "`"AssignableScopes`":")
        {
            #Add Lines after the selected pattern
            "`t`t`"/subscriptions/$subscriptionId`""
        }
  } | Set-Content $tempfile
#endregion

New-AzureRmRoleDefinition -InputFile $tempfile
New-AzureRmRoleAssignment -ObjectId $objectId -RoleDefinitionName "Encrypted VM Contributor" -Scope "/subscriptions/$subscriptionId"
