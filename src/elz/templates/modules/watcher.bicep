param elzRegionName string
param nsgWebId string
param nsgAppId string
param nsgDbId string
param nsgMgtId string
param lawId string
param lawResourceId string
param saId string
param location string 

resource watcher 'Microsoft.Network/networkWatchers@2021-05-01' = {
  name: 'NetworkWatcher_${elzRegionName}'
  location: location
  properties: {}
}

resource flowLogWeb 'Microsoft.Network/networkWatchers/flowLogs@2021-05-01' = {
  name: 'flowlog-web01'
  location: location
  parent: watcher
  properties: {
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        trafficAnalyticsInterval: 10
        workspaceId: lawId
        workspaceRegion: location
        workspaceResourceId: lawResourceId
     }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    storageId: saId
    targetResourceId: nsgWebId
  }
}

resource flowLogApp 'Microsoft.Network/networkWatchers/flowLogs@2021-05-01' = {
  name: 'flowlog-app01'
  location: location
  parent: watcher
  properties: {
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        trafficAnalyticsInterval: 10
        workspaceId: lawId
        workspaceRegion: location
        workspaceResourceId: lawResourceId
     }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    storageId: saId
    targetResourceId: nsgAppId
  }
}

resource flowLogDb 'Microsoft.Network/networkWatchers/flowLogs@2021-05-01' = {
  name: 'flowlog-db01'
  location: location
  parent: watcher
  properties: {
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        trafficAnalyticsInterval: 10
        workspaceId: lawId
        workspaceRegion: location
        workspaceResourceId: lawResourceId
     }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    storageId: saId
    targetResourceId: nsgDbId
  }
}

resource flowLogMgt 'Microsoft.Network/networkWatchers/flowLogs@2021-05-01' = {
  name: 'flowlog-mgt01'
  location: location
  parent: watcher
  properties: {
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        trafficAnalyticsInterval: 10
        workspaceId: lawId
        workspaceRegion: location
        workspaceResourceId: lawResourceId
     }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
    storageId: saId
    targetResourceId: nsgMgtId
  }
}
