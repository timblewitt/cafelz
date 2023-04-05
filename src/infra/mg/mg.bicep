targetScope = 'managementGroup'

param orgRootMg string = 'OrgRoot'
param singleplatform bool = false

resource mgliveorgroot 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: orgRootMg
  scope: tenant()
  properties: {
    displayName: orgRootMg
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
