param appName string
param environmentName string
param location string
param keyVaultName string
param appInsightsConnectionStringSecretName string = 'AppInsightsConnectionString'
param appInsightInstrumentationKeySecretName string = 'AppInsightInstrumentationKey'

// ========================================================
// Existing resources
resource keyVaultRes 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ========================================================
// Log Analytics Workspace
// ========================================================
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: format('{0}-{1}-{2}', 'law', appName, environmentName)
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}
// Application insights on top of the Log Analytics Workspace
resource appInsightsRes 'Microsoft.Insights/components@2020-02-02' = {
  name: format('{0}-{1}-{2}', 'ai', appName, environmentName)
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
resource appInsightConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01'= {
  parent: keyVaultRes
  name: appInsightsConnectionStringSecretName
  properties: {
    value: appInsightsRes.properties.ConnectionString
  }
}
resource appInsightInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01'= {
  parent: keyVaultRes
  name: appInsightInstrumentationKeySecretName
  properties: {
    value: appInsightsRes.properties.InstrumentationKey
  }
}

// ========================================================
// outputs
// ========================================================
output appInsightsConnectionString string = appInsightsRes.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsightsRes.properties.InstrumentationKey
