param name string = 'virtualnetwork'

param location string = resourceGroup().location

param addressSpacePrefixes array = [
  '10.0.0.0/16'
]

param dnsServers array = []

@minLength(1)
param subnetProfile array = [
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'aksnodepool1'
    addressPrefix: '10.0.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'test'
    addressPrefix: '10.0.3.0/24'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'data'
    addressPrefix: '10.0.4.0/24'
    delegations: [
      {
        name: 'Microsoft.DBforPostgreSQL.flexibleServers'
        properties: {
          serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
        }
      }
    ]
  }
]

param ddosProtectionPlan string = ''

param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/bicep/virtualnetwork'
}

//==============================================================

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressSpacePrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    ddosProtectionPlan: empty(ddosProtectionPlan) ? json('null') : {
      id: ddosProtectionPlan
    }
  }
  resource subnet 'subnets' = [for subnet in subnetProfile: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.addressPrefix
      privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? empty(subnet.privateEndpointNetworkPolicies) ? json('null') : subnet.privateEndpointNetworkPolicies : json('null')
      privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? empty(subnet.privateLinkServiceNetworkPolicies) ? json('null') : subnet.privateLinkServiceNetworkPolicies : json('null')
      delegations: contains(subnet, 'delegations') ? empty(subnet.delegations) ? json('null') : subnet.delegations : json('null')
    }
  }]
}

output id string = virtualnetwork.id
output name string = virtualnetwork.name
