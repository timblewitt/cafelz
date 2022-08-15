param elzSubName string

targetScope = 'tenant'

resource sub 'Microsoft.Subscription/subscriptionDefinitions@2017-11-01-preview' = {
  name: elzSubName
  properties: {
    offerType: 'MS-AZR-0017P'
    subscriptionDisplayName: elzSubName
  }
}
