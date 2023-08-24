param keyVaultName string
param secretName string
@secure()
param secretValue string

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName

}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01'={
  name: secretName
  parent: kv
  properties:{
    value: secretValue
  }
}

output secretId string = secret.id
output secretName string = secret.name
