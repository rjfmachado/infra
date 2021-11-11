targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/keyvault'
}

param sku object = {
  family: 'A'
  name: 'Standard'
}
param SoftDelete bool = true
param PurgeProtection bool = false
param accessPolicies array = []

resource keyvault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: sku
    enabledForTemplateDeployment: true
    enableSoftDelete: SoftDelete
    enablePurgeProtection: PurgeProtection ? true : json('null')
    publicNetworkAccess: 'enabled'
    accessPolicies: accessPolicies
  }
}

output name string = keyvault.name
output id string = keyvault.id
