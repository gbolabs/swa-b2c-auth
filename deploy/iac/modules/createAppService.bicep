param location string
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string
param appServicePlanName string
param appServicePlanSku string
param appServicePlanTier string
param appName string
param kvName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

var isProd = environmentName == 'prod'

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kvName
}

resource appPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: appServicePlanTier
  }
  kind: 'linux'
  properties: {
    reserved: true
    zoneRedundant: isProd ? true : false
  }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: format('{0}-{1}', appName, environmentName)
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appPlan.id
    httpsOnly: true
  }
}
resource appSiteConfigRes 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: app
  name: 'web'
  properties: {
    linuxFxVersion: 'DOTNETCORE|7.0'
  }
}
resource appAppConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: app
  name: 'appsettings'
  properties: {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    ASPNETCORE_ENVIRONMENT: environmentName
    KEYVAULTURL: kv.properties.vaultUri
    BackendUrl: app.properties.defaultHostName
    TenantId: subscription().tenantId
    RunSharepointSyncService: 'true'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    ApplicationInsightsAgent_EXTENSION_ENABLED: 'true'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
  }
}

module kvAccessPolicy 'keyVaultAccessPolicy.bicep' = {
  name: format('{0}-{1}', app.name, kv.name)
  params: {
    identityId: app.identity.principalId
    kvName: kv.name
    secretsPolicy: [
      'get'
      'list'
    ]
  }
}

output appServiceName string = app.name
output appUrl string = app.properties.defaultHostName
output appId string = app.id
