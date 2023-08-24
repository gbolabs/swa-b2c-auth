param kvName string
param secretsPolicy array
param identityId string

resource kv 'Microsoft.KeyVault/vaults@2023-02-01'existing={
  name:kvName
}

resource appServiceKvPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01'={
  parent: kv
  name: 'add'
  properties:{
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: identityId
        permissions: {
          secrets: secretsPolicy
        }
      }
    ]
  }
}
       
