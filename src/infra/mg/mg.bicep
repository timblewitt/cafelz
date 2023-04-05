targetScope = 'managementGroup'

param canary bool = false
param singleplatform bool = false

resource mgliveorgroot 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'LiveOrgRoot'
  scope: tenant()
  properties: {
    displayName: 'LiveOrgRoot'
  }
}

resource mgplatform 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'Platform'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgliveorgroot.id
      }
    }
    displayName: 'Platform'
  }
}

resource mgidentity 'Microsoft.Management/managementGroups@2021-04-01' = if (singleplatform == false) {
  name: 'Identity'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgplatform.id
      }
    }
    displayName: 'Identity'
  }
}

resource mgmanagement 'Microsoft.Management/managementGroups@2021-04-01' = if (singleplatform == false) {
  name: 'Management'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgplatform.id
      }
    }
    displayName: 'Management'
  }
}

resource mgconnectivity 'Microsoft.Management/managementGroups@2021-04-01' = if (singleplatform == false) {
  name: 'Connectivity'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgplatform.id
      }
    }
    displayName: 'Connectivity'
  }
}

resource mglandingzones 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'LandingZones'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgliveorgroot.id
      }
    }
    displayName: 'LandingZones'
  }
}

resource mgsandbox 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'Sandbox'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgliveorgroot.id
      }
    }
    displayName: 'Sandbox'
  }
}

resource mgdecommission 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'Decommission'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgliveorgroot.id
      }
    }
    displayName: 'Decommission'
  }
}

resource mgcanaryorgroot 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryOrgRoot'
  scope: tenant()
  properties: {
    displayName: 'CanaryOrgRoot'
  }
}

resource mgcanaryplatform 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryPlatform'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryorgroot.id
      }
    }
    displayName: 'CanaryPlatform'
  }
}

resource mgcanaryidentity 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryIdentity'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryplatform.id
      }
    }
    displayName: 'CanaryIdentity'
  }
}

resource mgcanarymanagement 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryManagement'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryplatform.id
      }
    }
    displayName: 'CanaryManagement'
  }
}

resource mgcanaryconnectivity 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryConnectivity'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryplatform.id
      }
    }
    displayName: 'CanaryConnectivity'
  }
}

resource mgcanarylandingzones 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanaryLandingZones'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryorgroot.id
      }
    }
    displayName: 'CanaryLandingZones'
  }
}

resource mgcanarysandbox 'Microsoft.Management/managementGroups@2021-04-01' = if (canary == true) {
  name: 'CanarySandbox'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: mgcanaryorgroot.id
      }
    }
    displayName: 'CanarySandbox'
  }
}

