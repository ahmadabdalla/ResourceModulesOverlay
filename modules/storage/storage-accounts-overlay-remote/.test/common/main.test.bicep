targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'ms.storage.storageaccounts-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'ssaorc'

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '<<namePrefix>>'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    location: location
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
  }
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-test-${serviceShort}'
  params: {
    location: location
    enableDefaultTelemetry: enableDefaultTelemetry
    name: '${namePrefix}${serviceShort}001'
    skuName: 'Standard_LRS'
    largeFileSharesState: 'Enabled'
    lock: 'CanNotDelete'
    enableHierarchicalNamespace: true
    enableSftp: true
    privateEndpoints: [
      {
        service: 'blob'
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
        privateDnsZoneGroup: {
          privateDNSResourceIds: [
            nestedDependencies.outputs.privateDNSZoneResourceId
          ]
        }
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    localUsers: [
      {
        storageAccountName: '${namePrefix}${serviceShort}001'
        name: 'testuser'
        hasSharedKey: false
        hasSshKey: true
        hasSshPassword: false
        homeDirectory: 'avdscripts'
        permissionScopes: [
          {
            permissions: 'r'
            service: 'blob'
            resourceName: 'avdscripts'
          }
        ]
      }
    ]
    blobServices: {
      containers: [
        {
          name: 'avdscripts'
          publicAccess: 'None'
          roleAssignments: [
            {
              roleDefinitionIdOrName: 'Reader'
              principalIds: [
                nestedDependencies.outputs.managedIdentityPrincipalId
              ]
              principalType: 'ServicePrincipal'
            }
          ]
        }
        {
          name: 'archivecontainer'
          publicAccess: 'None'
          metadata: {
            testKey: 'testValue'
          }
          enableWORM: true
          WORMRetention: 666
          allowProtectedAppendWrites: false
        }
      ]
      automaticSnapshotPolicyEnabled: true
      containerDeleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 10
      deleteRetentionPolicy: true
      deleteRetentionPolicyDays: 9
    }
    fileServices: {
      shares: [
        {
          name: 'avdprofiles'
          shareQuota: 5120
          roleAssignments: [
            {
              roleDefinitionIdOrName: 'Reader'
              principalIds: [
                nestedDependencies.outputs.managedIdentityPrincipalId
              ]
              principalType: 'ServicePrincipal'
            }
          ]
        }
        {
          name: 'avdprofiles2'
          shareQuota: 102400
        }
      ]
    }
    tableServices: {
      tables: [
        'table1'
        'table2'
      ]
    }
    queueServices: {
      queues: [
        {
          name: 'queue1'
          metadata: {
            key1: 'value1'
            key2: 'value2'
          }
          roleAssignments: [
            {
              roleDefinitionIdOrName: 'Reader'
              principalIds: [
                nestedDependencies.outputs.managedIdentityPrincipalId
              ]
              principalType: 'ServicePrincipal'
            }
          ]
        }
        {
          name: 'queue2'
          metadata: {}
        }
      ]
    }
    sasExpirationPeriod: '180.00:00:00'
    systemAssignedIdentity: true
    userAssignedIdentities: {
      '${nestedDependencies.outputs.managedIdentityResourceId}': {}
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalIds: [
          nestedDependencies.outputs.managedIdentityPrincipalId
        ]
        principalType: 'ServicePrincipal'
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
}
