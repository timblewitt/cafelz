#
# Update-IPAM
#
# This function updates the IPAM table with details of VNets associated with allocated address ranges
#
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Add records to an Azure storage table (storage account name is an application setting configured during function deployment)
$storageAccount = $env:ipamStorageAccount
$saTableName = 'ipam'
$saCtx = (Get-AzStorageAccount | where {$_.StorageAccountName -eq $storageAccount}).Context
$saTable = (Get-AzStorageTable –Name $saTableName –Context $saCtx).CloudTable

$unmanagedAddresses = 0
foreach ($sub in Get-AzSubscription) {
    Set-AzContext -Subscription $sub.Id
    foreach ($ipamRow in Get-AzTableRow -Table $saTable) {
        $vnet = Get-AzVirtualNetwork | where {$ipamRow.NetworkAddress -in $_.AddressSpace.AddressPrefixes}
        if ($vnet -ne $null) {
            Write-Verbose "$vnet.Name"
            Write-Host "$vnet.ResourceGroupName"
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

# Report all records
$results = "Unmanaged address ranges found: " + $unmanagedAddresses

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $results
})
