param appName string
param environment string
param location string
param swaName string
param subNetId string
param privateDnsZoneId string

resource statWebAppRes 'Microsoft.Web/staticSites@2022-09-01' existing = {
  name: swaName
}

resource peSwaRes 'Microsoft.Network/privateEndpoints@2022-11-01'={
  name: format('pe-swa-{0}-{1}',appName,environment)
  location: location
  properties:{
    subnet:{
      id: subNetId
    }
    privateLinkServiceConnections:[
      {
        name: 'default'
        properties:{
          privateLinkServiceId: statWebAppRes.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource swaPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-11-01'={
  name: format('pednszonegroup-swa-{0}-{1}',appName,environment)
  parent: peSwaRes
  properties:{
    privateDnsZoneConfigs:[
      {
        name: 'default'
        properties:{
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
