param elzSubName string
param elzRegionId string
param elzRegionName string
param elzMonitorRg string
param elzBackupRg string
param elzSecurityRg string
param elzNetworkRg string
param elzVnetName string
param elzVnetAddress string
param snetWeb string
param snetApp string
param snetDb string
param snetMgt string

targetScope = 'subscription'

resource rgMonitor 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: elzMonitorRg
  location: elzRegionName
}

resource rgBackup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: elzBackupRg
  location: elzRegionName
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: elzSecurityRg
  location: elzRegionName
}

resource rgNetwork 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: elzNetworkRg
  location: elzRegionName
}

module stdiag './modules/st.bicep' = {
  name: 'stDiagDeployment'
  scope: rgMonitor
  params: {
    stName: 'st${uniqueString(rgMonitor.id)}diag'
    stSku: 'Standard_LRS'
    stKind: 'StorageV2'
    location: elzRegionName
  }
}

module rsv './modules/rsv.bicep' = {
  name: 'rsvDeployment'
  scope: rgBackup
  params: {
    rsvName: 'rsv-${elzSubName}-${elzRegionId}-01'
    location: elzRegionName
  }
}

module rsvcfg './modules/rsvcfg.bicep' = {
  name: 'rsvcfgDeployment'
  scope: rgBackup
  params: {
    rsvName: rsv.outputs.rsvName
    rsvStorageType: 'GeoRedundant'
    location: elzRegionName
  }
}

module log './modules/log.bicep' = {
  name: 'logDeployment'
  scope: rgMonitor
  params: {
    logName: 'log-${elzSubName}-${elzRegionId}-01'
    aaId: aa.outputs.aaId
    location: elzRegionName
  }
}

module kv './modules/kv.bicep' = {
  name: 'kvDeployment'
  scope: rgSecurity
  params: {
    kvName: 'kv-${elzSubName}-${elzRegionId}-01'
    logId: log.outputs.logId
    location: elzRegionName
  }
}

module aa './modules/aa.bicep' = {
  name: 'aaDeployment'
  scope: rgMonitor
  params: {
    aaName: 'aa-${elzSubName}-${elzRegionId}-01'
    location: elzRegionName
  }
}

module nsg './modules/nsg.bicep' = {
  name: 'nsgDeployment'
  scope: rgNetwork
  params: {
    elzSubName: elzSubName
    elzRegionId: elzRegionId
    location: elzRegionName
  }
}

module vnet './modules/network.bicep' = {
  name: 'vnetDeployment'
  scope: rgNetwork
  params: {
    elzSubName: elzSubName
    elzRegionId: elzRegionId
    vnetName: elzVnetName
    vnetAddress: elzVnetAddress
    snetWeb: snetWeb
    snetApp: snetApp
    snetDb: snetDb
    snetMgt: snetMgt
    nsgWebId: nsg.outputs.nsgWebId
    nsgAppId: nsg.outputs.nsgAppId
    nsgDbId: nsg.outputs.nsgDbId
    nsgMgtId: nsg.outputs.nsgMgtId
    location: elzRegionName
  } 
}
