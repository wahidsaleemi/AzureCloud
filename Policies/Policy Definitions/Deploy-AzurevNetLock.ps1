 <#

.SYNOPSIS
Uses the lock-readonly-vnet.json template to lock the specified virtualNetwork.

.DESCRIPTION
See synopsis. Ensure that all the JSON files are in the same folder as the script.

.PARAMETER SubscriptionName 
The exact name of the subscription. If not specified, will default to "Contoso.Lab"

.PARAMETER resourceGroupName 
The name of the Resource Group for the virtual network to lock.

.PARAMETER vNetName 
The name of the virtual network to lock.

.PARAMETER lockName 
OPTIONAL. Provide a name for th lock such as "lock-readonly-vnet" If not specified, a default will be used.

.PARAMETER lockNotes 
OPTIONAL. Provide brief text to describe the lock. If not specified, a default will be used. 

.EXAMPLE
.\Deploy-AzurevNetLock.ps1 -SubscriptionName "Contoso.dlab" -ResourceGroupName "rg-ContosoLab-core" -vNetName "core-vnet1"

.EXAMPLE
.\Deploy-AzurevNetLock.ps1 -SubscriptionName "Contoso.dlab" -ResourceGroupName "rg-ContosoLab-core" -vNetName "core-vnet1" -lockName "Contoso.vnet.lock" -lockNotes "I didnt want to use the default notes."

.NOTES
Authored by Wahid Saleemi (Microsoft Services).

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$SubscriptionName = "Contoso.Lab",
    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$True)]
    [string]$vNetName,
    [string]$lockName,
    [string]$lockNotes
)

$error.clear()
$s = Select-AzureRmSubscription -SubscriptionName $SubscriptionName
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

$params = @{
    lockedResource = $vNetName
    lockName = $lockName
    lockNotes = $lockNotes
}

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile -TemplateParameterObject $params -Verbose 
