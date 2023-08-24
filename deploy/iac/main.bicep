@allowed([ 'dev', 'prod', 'test' ])
param environment string = 'dev'
@allowed([ 'd', 'p', 't' ])
param shortEnvironment string = environment == 'prod' ? 'p' : environment == 'test' ? 't' : 'd'
@allowed(['westeurope' ])
param location string = 'westeurope'
param appName string = 'allpurakalkulationstool'
param azureDevOpsServicePrincipalId string

param swaTokenSecretName string

param sqlServerAdminAccountName string = 'sqladmin'
@secure()
param sqlServerAdminPassword string
param sqlServerAllowedPublicIpAddresses array = []

param appServicePlanSku string = environment == 'prod' ? 'P0V3' : 'B1'
param appServicePlanTier string = environment == 'prod' ? 'PremiumV3' : 'Basic'


// Partner Id
resource partnerIdRes 'Microsoft.Resources/deployments@2020-06-01' = {
  name: 'pid-d97dce8b-1346-4b6d-b426-f9e59c7841bc'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// Requirements
// =============================
// Key Vault
module keyVaultRes 'modules/createKeyVault.bicep' = {
  name: 'keyVaultRes'
  params: {
    environmentShortName: shortEnvironment
    azureDevOpsServicePrincipalId: azureDevOpsServicePrincipalId
    location: location
    appName: appName
  }
}

// Log Analytics Workspace
module lawAppInsights 'modules/createLogAnalytics.bicep' = {
  name: 'lawAppInsights'
  params: {
    environmentName: environment
    keyVaultName: keyVaultRes.outputs.keyVaultName
    location: location
    appName: appName
  }
}

// App Service
module appServiceRes 'modules/createAppService.bicep' = {
  name: 'appServiceRes'
  params: {
    location: location
    appInsightsConnectionString: lawAppInsights.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: lawAppInsights.outputs.appInsightsInstrumentationKey
    appName: appName
    appServicePlanName: format('asp-{0}-{1}', appName, environment)
    appServicePlanSku: appServicePlanSku
    appServicePlanTier: appServicePlanTier
    environmentName: environment
    kvName: keyVaultRes.outputs.keyVaultName
  }
}

// Azure Static Web App
module swa 'modules/createAzureStaticWebApp.bicep' = {
  name: format('swa-{0}-{1}', appName, environment)
  params: {
    keyVaultName: keyVaultRes.outputs.keyVaultName
    appName: appName
    backendResourceId: appServiceRes.outputs.appId
    swaTokenSecretName: swaTokenSecretName
    environment: environment
    location: location
  }
}

// Outputs
output appServiceName string = appServiceRes.outputs.appServiceName
output keyVaultName string = keyVaultRes.outputs.keyVaultName
output keyVaultUrl string = keyVaultRes.outputs.keyVaultUrl
