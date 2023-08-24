param appName string
param environmentName string
param location string
param sqlServerName string
param sqlServerPrivateEndpointName string = format('pe-sqlserver-{0}-{1}', appName,environmentName)
param privateDatabaseDnsZoneId string
param vnetSubnetId string

resource sqlServerRes 'Microsoft.Sql/servers@2022-11-01-preview' existing = {
  name: sqlServerName
}

resource endpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: sqlServerPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: vnetSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: sqlServerPrivateEndpointName
        properties: {
          privateLinkServiceId: sqlServerRes.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource sqlPrivateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-11-01' = {
  name: format('pldnszonegroup-database-{0}-{1}', appName, environmentName)
  parent: endpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: sqlServerPrivateEndpointName
        properties: {
          privateDnsZoneId: privateDatabaseDnsZoneId
        }
      }
    ]
  }
}
