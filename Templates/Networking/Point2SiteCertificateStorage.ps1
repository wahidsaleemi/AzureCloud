

#Use productionkeyvault
Select-AzureRmSubscription -SubscriptionName ""
$kv = "kv-prod-ops"

$pass1 = ''
$pass2 = ''

#Store some passwords
$tag = @{Description="This is the password for the P2S VPN Root Certificate used for Lab subscriptions."}
$rootpwd = ConvertTo-SecureString –String $pass1 –AsPlainText –Force
$secret = Set-AzureKeyVaultSecret -VaultName $kv -Name 'LabP2SRootPassword' -SecretValue $rootpwd -Tag $tag

$tag = @{Description="This is the password for the P2S VPN Client Certificates used for Lab subscriptions."}
$clientpwd = ConvertTo-SecureString –String $pass2 –AsPlainText –Force
$secret = Set-AzureKeyVaultSecret -VaultName $kv -Name 'LabP2SClientPassword' -SecretValue $rootpwd -Tag $tag

#Update the policy
$objectId = "guid"
Set-AzureRmKeyVaultAccessPolicy -VaultName $kv.VaultName -ObjectId $objectId -PermissionsToCertificates all


#Store root certificate
$tag = @{Description="Point-to-site VPN root certificate for Lab subscription"}
$rootkey = Import-AzureKeyVaultCertificate -VaultName $kv -Name 'LabP2SRoot' `
        -FilePath 'c:\Temp\LabP2SRootPrivateKey.pfx' -Password $rootpwd -Tag $tag

#Store client certificates
1..5 | ForEach-Object {
$text = "Point-to-site VPN client certificate number $_ for Lab subscription"
$tag = @{Description=$text}
$clientkey = Import-AzureKeyVaultCertificate -VaultName $kv -Name "LabP2SClient$_" `
        -FilePath "c:\temp\LabP2SClient$_.pfx" -Password $clientpwd -Tag $tag
}

$rootkey.id
$clientkey.Id

##############################################
#Get the secret
$password = Get-AzureKeyVaultSecret -VaultName "kv-prod-ops" -Name "LabP2SClientPassword"
Get-AzureKeyVaultKey -VaultName $kv -Name "LabP2SClient1"


$secretName = "TestCert"
$kvSecret = Get-AzureKeyVaultSecret -VaultName $vaultName -Name $certificateName
$kvSecretBytes = [System.Convert]::FromBase64String($kvSecret.SecretValueText)
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)


