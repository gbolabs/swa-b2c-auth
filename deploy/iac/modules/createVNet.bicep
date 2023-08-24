param appName string
param environmentName string
param location string
param vnetAddressPrefix string
param defaultSubnetConfig object
param appSubetConfig object


// ========================================================
// Virtual Network
// --------------------------------------------------------
// The virtual network must be declared with its subnets
// otherwise wenn created into two iterations, with dedicated
// subnet resources, the second iteration will fail because
// because the BICEP differential engine will try to delete
// the subnet before applying the update. This will fails
// as the subnet do exists.
// ========================================================
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: format('vnet-{0}-{1}', appName, environmentName)
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: defaultSubnetConfig.name
        properties: {
          addressPrefix: defaultSubnetConfig.addressPrefix
        }
      }
      {
        name: appSubetConfig.name
        properties: {
          addressPrefix: appSubetConfig.addressPrefix
          delegations: [
            {
              name: 'appService'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
  resource defaultSubnetRes 'subnets' existing = {
    name: defaultSubnetConfig.name
  }
  resource appSubnetRes 'subnets' existing = {
    name: appSubetConfig.name
  }
}

module privateDatabaseDnsZone 'privateDnsZone.bicep' = {
  name: 'privateDatabaseDnsZone'
  params: {
    zoneName: 'privatelink${environment().suffixes.sqlServerHostname}'
    location: 'global'
  }
}
module privateDnsZone 'privateDnsZone.bicep' = {
  name: 'privateDnsZone'
  params: {
    zoneName: format('{0}.{1}.private', appName, environmentName)
    location: 'global'
  }
}
module vnetLinkDefault 'dnsZoneVirtualNetworkLink.bicep' = {
  name: 'vnetLinkDefault'
  params: {
    location: 'global'
    privateDnsZoneName: privateDnsZone.outputs.zoneName
    autoRegistration: true
    vnetName: vnet.name
  }
}
module vnetLinkDatabase 'dnsZoneVirtualNetworkLink.bicep' = {
  name: 'vnetLinkDatabase'
  params: {
    location: 'global'
    privateDnsZoneName: privateDatabaseDnsZone.outputs.zoneName
    vnetName: vnet.name
  }
}


// ========================================================
// outputs
// --------------------------------------------------------
output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetDefaultSubnetId string = vnet::defaultSubnetRes.id
output vnetAppSubnetId string = vnet::appSubnetRes.id
output privateDatabaseDnsZoneId string = privateDatabaseDnsZone.outputs.zoneId
