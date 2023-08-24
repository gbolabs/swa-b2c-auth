param vnetName string
param privateDnsZoneName string
param autoRegistration bool = false
param location string = 'global'

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing ={
  name: vnetName
}
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource dnsZoneVNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' ={
  parent: privateDnsZone
  name: 'vnetLink'
  location: location
  properties:{
    registrationEnabled: autoRegistration
    virtualNetwork: {
      id: vnet.id
    }
  }
}
