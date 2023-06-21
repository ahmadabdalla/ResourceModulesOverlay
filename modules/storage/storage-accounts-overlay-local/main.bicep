@maxLength(24)
@description('Required. Name of the Storage Account.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = true

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
@description('Optional. Type of Storage Account to create.')
param kind string = 'StorageV2'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('Optional. Storage Account Sku Name.')
param skuName string = 'Standard_GRS'

@allowed([
  'Premium'
  'Hot'
  'Cool'
])
@description('Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.')
param accessTier string = 'Hot'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Allow large file shares if sets to \'Enabled\'. It cannot be disabled once it is enabled. Only supported on locally redundant and zone redundant file shares. It cannot be set on FileStorage storage accounts (storage accounts for premium file shares).')
param largeFileSharesState string = 'Disabled'

@description('Optional. Provides the identity based authentication settings for Azure Files.')
param azureFilesIdentityBasedAuthentication object = {}

@description('Optional. A boolean flag which indicates whether the default authentication is OAuth or not.')
param defaultToOAuthAuthentication bool = false

@description('Optional. Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is null, which is equivalent to true.')
param allowSharedKeyAccess bool = true

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints array = []

@description('Optional. The Storage Account ManagementPolicies Rules.')
param managementPolicyRules array = []

@description('Optional. Sets the custom domain name assigned to the storage account. Name is the CNAME source.')
param customDomainName string = ''

@description('Optional. Indicates whether indirect CName validation is enabled. This should only be set on updates.')
param customDomainUseSubDomainName bool = false

@description('Conditional. If true, enables Hierarchical Namespace for the storage account. Required if enableSftp or enableNfsV3 is set to true.')
param enableHierarchicalNamespace bool = false

@description('Optional. If true, enables Secure File Transfer Protocol for the storage account. Requires enableHierarchicalNamespace to be true.')
param enableSftp bool = false

@description('Optional. Local users to deploy for SFTP authentication.')
param localUsers array = []

@description('Optional. Enables local users feature, if set to true.')
param isLocalUserEnabled bool = false

@description('Optional. If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
param enableNfsV3 bool = false

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Allows HTTPS traffic only to storage service if sets to true.')
param supportsHttpsTrafficOnly bool = true

@description('Conditional. The resource ID of a key vault to reference a customer managed key for encryption from. Required if \'cMKKeyName\' is not empty.')
param cMKKeyVaultResourceId string = ''

@description('Optional. The name of the customer managed key to use for encryption. Cannot be deployed together with the parameter \'systemAssignedIdentity\' enabled.')
param cMKKeyName string = ''

@description('Conditional. User assigned identity to use when fetching the customer managed key. Required if \'cMKKeyName\' is not empty.')
param cMKUserAssignedIdentityResourceId string = ''

@description('Optional. The version of the customer managed key to reference for encryption. If not provided, latest is used.')
param cMKKeyVersion string = ''

@description('Optional. The SAS expiration period. DD.HH:MM:SS.')
param sasExpirationPeriod string = ''

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

module storageAccountOverlayLocal '../storage-accounts/main.bicep' = {
  name: '${name}-local'
  params: {
    name: name
    location: location
    kind: kind
    skuName: skuName
    userAssignedIdentities: userAssignedIdentities
    systemAssignedIdentity: systemAssignedIdentity
    tags: tags
    lock: lock
    roleAssignments: roleAssignments
    enableDefaultTelemetry: false
    localUsers: localUsers
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    allowCrossTenantReplication: false
    allowedCopyScope: 'PrivateLink'
    customDomainName: customDomainName
    customDomainUseSubDomainName: customDomainUseSubDomainName
    dnsEndpointType: 'Standard'
    isLocalUserEnabled: isLocalUserEnabled
    cMKKeyName: cMKKeyName
    cMKKeyVaultResourceId: cMKKeyVaultResourceId
    cMKKeyVersion: cMKKeyVersion
    cMKUserAssignedIdentityResourceId: cMKUserAssignedIdentityResourceId
    requireInfrastructureEncryption: true
    accessTier: accessTier
    sasExpirationPeriod: sasExpirationPeriod
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    enableHierarchicalNamespace: enableHierarchicalNamespace
    enableSftp: enableSftp
    enableNfsV3: false
    largeFileSharesState: largeFileSharesState
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    privateEndpoints: privateEndpoints
    allowBlobPublicAccess: false
    azureFilesIdentityBasedAuthentication: azureFilesIdentityBasedAuthentication
    managementPolicyRules: managementPolicyRules
  }
}

@description('The resource ID of the deployed storage account.')
output resourceId string = storageAccountOverlayLocal.outputs.resourceId

@description('The name of the deployed storage account.')
output name string = storageAccountOverlayLocal.outputs.name

@description('The resource group of the deployed storage account.')
output resourceGroupName string = resourceGroup().name

@description('The primary blob endpoint reference if blob services are deployed.')
output primaryBlobEndpoint string = storageAccountOverlayLocal.outputs.name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(storageAccountOverlayLocal.outputs, 'systemAssignedPrincipalId') ? storageAccountOverlayLocal.outputs.systemAssignedPrincipalId : ''

@description('The location the resource was deployed into.')
output location string = storageAccountOverlayLocal.outputs.location
