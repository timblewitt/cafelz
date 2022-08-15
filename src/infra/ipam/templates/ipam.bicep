param regionName string
param regionId string
param nwSubName string
param mgmtSubName string
param rgIpamName string
param rgMonitorName string

targetScope = 'subscription'

resource rgIpam 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgIpamName
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
    logName: 'log-${mgmtSubName}-${regionId}-01'
    aaName: 'aa-${mgmtSubName}-${regionId}-01'
    location: regionName
  }
}

module fa './modules/fa.bicep' = {
  name: 'faDeployment'
  scope: rgIpam
  params: {
    stName: 'st${uniqueString(rgIpam.id)}ipam'
    stSku: 'Standard_GRS'
    stKind: 'StorageV2'
    tableName: 'ipam'
    planName: 'plan-${nwSubName}-${regionId}-ipam'
    planSkuName: 'EP1'
    planTier: 'Premium'
    faName: 'fa-${nwSubName}-${regionId}-ipam'
    logId: monitor.outputs.logId
    location: regionName
  }
}

