@description('Name of the Azure Function App')
param functionAppName string
@description('Name of the existing Cognitive Services account')
param account_name string
@description('Location for Bing Grounding resource (usually global)')
param location string = 'global'

// Reference existing Cognitive Services account
resource accountResource 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: account_name
  scope: resourceGroup()
}

// Provision Bing Grounding resource
var bingSearchName = 'bingsearch-${account_name}'
resource bingSearch 'Microsoft.Bing/accounts@2020-06-10' = {
  name: bingSearchName
  location: location
  sku: { name: 'G1' }
  kind: 'Bing.Grounding'
}

// Create a connection from the Cognitive Services account to the Bing Grounding resource
resource bingConnection 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = {
  name: '${account_name}-bingsearchconnection'
  parent: accountResource
  properties: {
    category: 'ApiKey'
    target: 'https://api.bing.microsoft.com/'
    authType: 'ApiKey'
    credentials: {
      key: listKeys(bingSearch.id, '2020-06-10').key1
    }
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      Location: bingSearch.location
      ResourceId: bingSearch.id
    }
  }
}

// Storage account for function state and logs
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${functionAppName}storage'
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

// App Service plan for the Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${functionAppName}-plan'
  location: resourceGroup().location
  sku: { name: 'Y1'; tier: 'Dynamic' }
}

// Function App using System-Assigned Identity
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: resourceGroup().location
  kind: 'functionapp'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        { name: 'AzureWebJobsStorage'; value: storageAccount.properties.primaryEndpoints.blob }
        { name: 'FUNCTIONS_WORKER_RUNTIME'; value: 'python' }
        { name: 'PROJECT_ENDPOINT'; value: '<your agent service endpoint>' }
        { name: 'MODEL_DEPLOYMENT_NAME'; value: '<your model deployment>' }
        { name: 'BING_CONNECTION_ID'; value: bingConnection.id }
      ]
      http20Enabled: true
    }
  }
}

output functionAppEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/Run'
