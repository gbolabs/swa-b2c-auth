param appName string
param environment string
@allowed([ 'westeurope' ])
param location string
@allowed([ 'Free', 'Standard' ])
param swaSku string = 'Standard'
param keyVaultName string
param swaTokenSecretName string

param backendLocation string = location
param backendResourceId string

resource statWebAppRes 'Microsoft.Web/staticSites@2022-09-01' = {
  name: format('swa-{0}-{1}', appName, environment)
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  sku: {
    name: swaSku
  }
  properties: {
    stagingEnvironmentPolicy: 'Disabled'
  }
}

resource swaBackend 'Microsoft.Web/staticSites/linkedBackends@2022-09-01' = {
  name: format('{0}/default', statWebAppRes.name)
  kind: 'app'
  properties: {
    backendResourceId: backendResourceId
    region: backendLocation
  }
}

module swaDeployTokenSecret 'keyVaultSecret.bicep' = {
  name: format('{0}-deploy-token', statWebAppRes.name)
  params: {
    keyVaultName: keyVaultName
    secretName: swaTokenSecretName
    secretValue: statWebAppRes.listSecrets().properties.apiKey
  }
}

// output swaTokenSecretName string = swaDeployTokenSecret.outputs.secretName
// // To re-use the token within the deployment token
// #disable-next-line outputs-should-not-contain-secrets
// output swaTokenSecretValue string = statWebAppRes.listSecrets().properties.apiKey
