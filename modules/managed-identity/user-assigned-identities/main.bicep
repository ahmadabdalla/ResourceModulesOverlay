@description('Optional. Name of the User Assigned Identity.')
param name string = guid(resourceGroup().id)

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module userMsi 'ts/overlays:managed-identity.user-assigned-identities:latest' = {
  name: '${uniqueString(deployment().name, location)}-UserMSI'
  params: {
    name: name
    enableDefaultTelemetry: false
    tags: {
      moduleType: 'overlay'
      version: '1.0'
    }
  }
}

@description('The name of the user assigned identity.')
output name string = userMsi.outputs.name

@description('The resource ID of the user assigned identity.')
output resourceId string = userMsi.outputs.resourceId

@description('The principal ID (object ID) of the user assigned identity.')
output principalId string = userMsi.outputs.principalId

@description('The client ID (application ID) of the user assigned identity.')
output clientId string = userMsi.outputs.clientId

@description('The resource group the user assigned identity was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = userMsi.outputs.location
