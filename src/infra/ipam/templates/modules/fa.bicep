param stName string
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
param stSku string
param stKind string
param tableName string
param planName string
param planSkuName string
param planTier string
param faName string
param faplanId string
param faStName string
param faStId string
param faStApiVersion string
param logId string
param location string

resource st 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: stName
  location: location
  sku: {
    name: stSku
  }
  kind: stKind
}

resource tableservice 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  name: 'default'
  parent: st
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-04-01' = {
  name: tableName
  parent: tableservice
}

resource plan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: planName
  location: location
  sku: {
    name: planSkuName
    tier: planTier
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: faName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: logId
  }
}

resource fa 'Microsoft.Web/sites@2022-03-01' = {
  name: faName
  kind: 'functionapp'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: faplanId
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'powershell'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${faStName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${st.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${faStName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${st.listKeys().keys[0].value}'
        }        
      ]
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
  }
}
