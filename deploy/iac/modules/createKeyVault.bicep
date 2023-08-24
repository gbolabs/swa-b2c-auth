param appName string
@allowed(['d', 'p','t'])
param environmentShortName string
param location string
param azureDevOpsServicePrincipalId string
param keyVaultSku string = 'standard'
param keyVaultFamily string = 'A'

// ========================================================
// Key Vault
// ========================================================
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01'= {
  name: format('{0}-{1}-{2}', 'kv', appName, environmentShortName)
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: keyVaultFamily
      name: keyVaultSku
    }
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    enableSoftDelete: true
  }
}

// Access Policies
resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01'= {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      // Grant Azure DevOps ServicePrincipal to list and get secrets
      {
        tenantId: subscription().tenantId
        objectId: azureDevOpsServicePrincipalId
        permissions: {
          secrets: [
            'get' // Used to list secrets and integrate with Azure Pipelines
            'list' // Used to list secrets and integrate with Azure Pipelines
            'set' // Used to set further secrets
          ]
        }
      }
      // User
      {
        tenantId:subscription().tenantId
        objectId: '74fa1dc1-96ae-4b65-9905-9004b475ff9d'
        permissions:{
          secrets:[
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}

// ========================================================
output keyVaultName string = keyVault.name
output keyVaultUrl string = keyVault.properties.vaultUri
