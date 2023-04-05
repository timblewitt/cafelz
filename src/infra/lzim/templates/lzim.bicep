param orgId string
param regionName string
param regionId string
param mgmtSubName string
param rgLzimName string
param rgMonitorName string

targetScope = 'subscription'

resource rgLzim 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgLzimName
  location: regionName
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgMonitorName
  location: regionName
}

module monitor './modules/monitor.bicep' = {
  name: 'monitorDeployment'
  scope: rgMonitor
  params: {
    logName: 'log-${orgId}-${mgmtSubName}-${regionId}-01'
    aaName: 'aa-${orgId}-${mgmtSubName}-${regionId}-01'
    location: regionName
  }
}

module fa './modules/fa.bicep' = {
  name: 'faDeployment'
  scope: rgLzim
  params: {
    stName: 'st${uniqueString(rgLzim.id)}lzim'
    stSku: 'Standard_GRS'
    stKind: 'StorageV2'
    tableName: 'lzim'
    planName: 'plan-${orgId}-${mgmtSubName}-${regionId}-lzim'
    planSkuName: 'EP1'
    planTier: 'Premium'
    faName: 'fa-${orgId}-${mgmtSubName}-${regionId}-lzim'
    logId: monitor.outputs.logId
    location: regionName
  }
}
