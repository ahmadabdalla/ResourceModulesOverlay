@description('Required. Name of the private endpoint resource to create.')
param name string

@description('Required. Resource ID of the subnet where the endpoint needs to be created.')
param subnetResourceId string

@description('Required. Resource ID of the resource that needs to be connected to the network.')
param serviceResourceId string

@description('Optional. Application security groups in which the private endpoint IP configuration is included.')
param applicationSecurityGroups array = []

@description('Optional. The custom name of the network interface attached to the private endpoint.')
param customNetworkInterfaceName string = ''

@description('Optional. A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.')
param ipConfigurations array = []

@description('Required. Subtype(s) of the connection to be created. The allowed values depend on the type serviceResourceId refers to.')
param groupIds array

@description('Optional. The private DNS zone group configuration used to associate the private endpoint with one or multiple private DNS zones. A DNS zone group can support up to 5 DNS zones.')
param privateDnsZoneGroup object = {}

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Tags to be applied on all resources/resource groups in this deployment.')
param tags object = {}

@description('Optional. Custom DNS configurations.')
param customDnsConfigs array = []

@description('Optional. Manual PrivateLink Service Connections.')
param manualPrivateLinkServiceConnections array = []

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = false

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

module privateEndpointOverlayLocal '../private-endpoints/main.bicep' = {
  name: '${name}-local'
  params: {
    location: location
    lock: lock
    tags: tags
    enableDefaultTelemetry: false
    groupIds: groupIds
    name: name
    serviceResourceId: serviceResourceId
    subnetResourceId: subnetResourceId
    applicationSecurityGroups: applicationSecurityGroups
    customDnsConfigs: customDnsConfigs
    customNetworkInterfaceName: customNetworkInterfaceName
    ipConfigurations: ipConfigurations
    manualPrivateLinkServiceConnections: manualPrivateLinkServiceConnections
    privateDnsZoneGroup: privateDnsZoneGroup
  }
}

@description('The resource group the private endpoint was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the private endpoint.')
output resourceId string = privateEndpointOverlayLocal.outputs.resourceId

@description('The name of the private endpoint.')
output name string = privateEndpointOverlayLocal.outputs.name

@description('The location the resource was deployed into.')
output location string = privateEndpointOverlayLocal.outputs.location
