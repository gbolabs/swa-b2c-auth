param startIpAddress string
param endIpAddress string
param ruleName string
param serverName string

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' existing = {
  name: serverName
}

resource sqlServerFirewallRule 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: sqlServer
  name: ruleName
  properties: {    
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}
