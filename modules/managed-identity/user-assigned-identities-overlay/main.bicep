@description('Required. Name of the User Assigned Identity.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

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

module userMsiOverlay '../user-assigned-identities/main.bicep' = {
  name: name
  params: {
    location: location
    tags: {
      type: 'overlay'
      version: 'source-control'
    }
  }
}

@description('The name of the user assigned identity.')
output name string = userMsiOverlay.outputs.name

@description('The resource ID of the user assigned identity.')
output resourceId string = userMsiOverlay.outputs.resourceId

@description('The principal ID (object ID) of the user assigned identity.')
output principalId string = userMsiOverlay.outputs.principalId

@description('The client ID (application ID) of the user assigned identity.')
output clientId string = userMsiOverlay.outputs.clientId

@description('The resource group the user assigned identity was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = userMsiOverlay.outputs.location
