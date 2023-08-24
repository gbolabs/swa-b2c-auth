param resourceLocation string
param sqlServerName string
param sqlDbName string
param sqlDbMaxSizeInGb int
param sqlServerAdminAccountName string
@secure()
param sqlServerAdminAccountPassword string
@description('List of allowed IP addresses for SQL Server firewall rules. Format [{description, startIpAddress, endIpAddress}]')
param sqlServerAllowedIpAddresses array
param sqlDbSkuName string
param sqlDbSkuTier string
param sqlDbSkuCapacity int = 1
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string
param keyVaultName string

// =============================
// SQL Server resources
// =============================
resource sqlServerRes 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: resourceLocation
  properties: {
    administratorLogin: sqlServerAdminAccountName
    administratorLoginPassword: sqlServerAdminAccountPassword
    publicNetworkAccess: environmentName == 'dev' ? 'Enabled' : 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
    version: '12.0'
  }
}

module sqlServerFirewallModule 'createAzureSqlFirewallRule.bicep' = [for item in sqlServerAllowedIpAddresses: if (environmentName == 'dev') {
  name: item.description
  params: {
    serverName: sqlServerName
    ruleName: item.description
    startIpAddress: item.startIpAddress
    endIpAddress: item.endIpAddress
  }
  dependsOn: [
    sqlServerRes
  ]
}]

// =============================
// SQL Database resources
// =============================
resource sqlDb 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent: sqlServerRes
  name: sqlDbName
  location: resourceLocation
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: sqlDbMaxSizeInGb * 1024 * 1024 * 1024
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: environmentName == 'prod' ? true : false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: environmentName == 'prod' ? 'Zone' : 'Local'
    isLedgerOn: false
  }
  sku: {
    name: sqlDbSkuName
    tier: sqlDbSkuTier
    capacity: sqlDbSkuCapacity
  }
}

// =============================
// Key Vault resources
// =============================
module kvSecretAdminPassword 'keyVaultSecret.bicep' = {
  name: 'kvSecretAdminPassword'
  params: {
    keyVaultName: keyVaultName
    secretName: 'sqlServerAdminAccountPassword'
    secretValue: sqlServerAdminAccountPassword
  }
}
module kvSecretAdminAccount 'keyVaultSecret.bicep' = {
  name: 'kvSecretAdminAccount'
  params: {
    keyVaultName: keyVaultName
    secretName: 'sqlServerAdminAccountName'
    secretValue: sqlServerAdminAccountName
  }
}
module kvDbConnectionString 'keyVaultSecret.bicep' = {
  name: 'kvDbConnectionString'
  params: {
    keyVaultName: keyVaultName
    secretName: 'sqlConnectionString'
    secretValue: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDb.name};Persist Security Info=False;User ID=${sqlServerAdminAccountName};Password=${sqlServerAdminAccountPassword};Encrypt=True;'
  }
}

output sqlConnectionStringKvSecretName string = kvDbConnectionString.outputs.secretName
output sqlConnectionStringKvSecretId string = kvDbConnectionString.outputs.secretId
output sqlServerId string = sqlServerRes.id
output sqlDbId string = sqlDb.id
output sqlServerName string = sqlServerRes.name
