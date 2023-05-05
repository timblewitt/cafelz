param orgId string
param elzSubName string
param elzRegionId string
param location string 

resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'nsg-${orgId}-${elzSubName}-${elzRegionId}-web'
  location: location
  properties: {
    securityRules: [
      {
      name: 'Drop_All'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
        }      
      }
    ]
  }
}

resource nsgApp 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'nsg-${orgId}-${elzSubName}-${elzRegionId}-app'
  location: location
  properties: {
    securityRules: [
      {
      name: 'Drop_All'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
        }      
      }
    ]
  }
}

resource nsgDb 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'nsg-${orgId}-${elzSubName}-${elzRegionId}-db'
  location: location
  properties: {
    securityRules: [
      {
      name: 'Drop_All'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
        }      
      }
    ]
  }
}

resource nsgMgt 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'nsg-${orgId}-${elzSubName}-${elzRegionId}-mgt'
  location: location
  properties: {
    securityRules: [
      {
      name: 'Drop_All'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
        }      
      }
    ]
  }
}

output nsgWebId string = nsgWeb.id
output nsgAppId string = nsgApp.id
output nsgDbId string = nsgDb.id
output nsgMgtId string = nsgMgt.id
