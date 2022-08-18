#
# Update-IPAM
#
# This function updates the IPAM table with details of VNets associated with allocated address ranges
#

Function Update-IPAM {
    [cmdletbinding()]
    # Add records to an Azure storage table (storage account name is an application setting configured during function deployment)
    $storageAccount = $env:ipamStorageAccount
    $saTableName = 'ipam'
    $saCtx = (Get-AzStorageAccount | where {$_.StorageAccountName -eq $storageAccount}).Context
    $saTable = (Get-AzStorageTable –Name $saTableName –Context $saCtx).CloudTable

    $unmanagedAddresses = 0
    $subs = Get-AzSubscription
    foreach ($sub in $subs) {
        Set-AzContext -Subscription $sub.Id
        foreach ($ipamRow in Get-AzTableRow -Table $saTable) {
            $vnet = Get-AzVirtualNetwork | where {$ipamRow.NetworkAddress -in $_.AddressSpace.AddressPrefixes}
            if ($vnet -ne $null) {
                $ipamRow.Subscription = $sub.Name
                $ipamRow.VNetName = $vnet.Name
                $ipamRow.ResourceGroup = $vnet.ResourceGroupName
                if ($ipamRow.Allocated -ne $true) {
                    $ipamRow.Allocated = $true
                    $ipamRow.Notes = 'Updated by Update-IPAM'
                    $unmanagedAddresses += 1
                }
                $ipamRow | Update-AzTableRow -Table $saTable
            }    
        }
    }
}