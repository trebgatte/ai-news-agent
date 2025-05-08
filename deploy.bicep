@description('Name of the Azure Function App')
param functionAppName string
@description('Location for all resources')
param location string = resourceGroup().location

// Storage account for function state and logs
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${functionAppName}storage'
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

// App Service plan for the Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${functionAppName}-plan'
  location: location
  sku: { name: 'Y1'; tier: 'Dynamic' }
}

// Bing Grounding with Bing Cognitive Services resource
resource bingAccount 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: '${functionAppName}-bing'
  location: location
  kind: 'Bing.Search'
  sku: { name: 'S0' }
  properties: {}
}

// Function App using System-Assigned Identity
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        { name: 'AzureWebJobsStorage'; value: storageAccount.properties.primaryEndpoints.blob }
        { name: 'FUNCTIONS_WORKER_RUNTIME'; value: 'python' }
        // OpenAI endpoint and key from Key Vault
        { name: 'AZURE_OPENAI_ENDPOINT'; value: '@Microsoft.KeyVault(VaultName=myVault;SecretName=OpenAIEndpoint)' }
        { name: 'AZURE_OPENAI_KEY'; value: '@Microsoft.KeyVault(VaultName=myVault;SecretName=OpenAIKey)' }
        // Bing Grounding resource endpoint and key
        { name: 'BING_SEARCH_ENDPOINT'; value: bingAccount.properties.endpoint }
        { name: 'BING_SEARCH_KEY'; value: listKeys(bingAccount.id, '2021-10-01').key1 }
      ]
      http20Enabled: true
    }
  }
}

output functionAppEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/Run'
