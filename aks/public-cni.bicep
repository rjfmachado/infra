param name string
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/aks'
}

param clusterVersion string = '1.21.2'

param sku object = {
  name: 'Basic'
  tier: 'Free'
}

param networkProfile object = {
  networkMode: 'transparent'
  networkPlugin: 'azure'
  serviceCidr: '10.254.0.0/16'
  dnsServiceIP: '10.254.0.10'
  outboundType: 'loadBalancer'
  loadBalancerSku: 'standard'
  loadBalancerProfile: {
    managedOutboundIPs: {
      count: 1
    }
  }
}

param addonProfiles object = {
  azureKeyvaultSecretsProvider: {
    enabled: true
    config: {
      enableSecretRotation: 'false'
    }
  }
  omsagent: {
    enabled: false
    config: {
      logAnalyticsWorkspaceResourceID: ''
    }
  }
  azurepolicy: {
    enabled: false
    config: {
      version: 'v2'
    }
  }
}

param identityProfile object = {}

param autoUpgradeProfile object = {
  upgradeChannel: 'node-image'
}

param nodePools array = [
  {
    name: 'system'
    count: 1
    minCount: 1
    maxCount: 6
    enableAutoScaling: true
    enableEncryptionAtHost: false
    enableNodePublicIP: false
    mode: 'System'
    vnetSubnetID: 'subnetId'
    vmSize: 'Standard_DS3_v2'
    osDiskType: 'Ephemeral'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    orchestratorVersion: clusterVersion
    upgradeSettings: {
      maxSurge: '1'
    }
    nodeTaints: [
      'CriticalAddonsOnly=true:NoSchedule'
    ]
  }
  // {
  //   name: 'user'
  //   count: 1
  //   minCount: 1
  //   maxCount: 6
  //   enableAutoScaling: true
  //   enableEncryptionAtHost: false
  //   enableNodePublicIP: false
  //   mode: 'User'
  //   vnetSubnetID: akssubnet.id
  //   vmSize: 'Standard_DS3_v2'
  //   osDiskType: 'Ephemeral'
  //   availabilityZones: [
  //     '1'
  //     '2'
  //     '3'
  //   ]
  //   orchestratorVersion: clusterVersion
  //   upgradeSettings: {
  //     maxSurge: '1'
  //   }
  // }
]

resource aks 'Microsoft.ContainerService/managedClusters@2021-09-01' = {
  name: name
  location: location
  tags: tags
  sku: sku

  identity: identityProfile

  properties: {
    dnsPrefix: name
    kubernetesVersion: clusterVersion
    enableRBAC: true
    nodeResourceGroup: '${name}-nodes'

    networkProfile: networkProfile

    agentPoolProfiles: nodePools

    autoUpgradeProfile: autoUpgradeProfile

    addonProfiles: addonProfiles
  }
}

resource aksMaintenance 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2021-09-01' = {
  name: 'askmaintenance'
  parent: aks
  properties: {
    timeInWeek: [
      {
        day: 'Sunday'
      }
    ]
  }
}

output addons object = aks.properties.addonProfiles
output identity object = aks.properties.identityProfile
