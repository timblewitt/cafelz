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
Write-Host "TIMB1: $storageAccount"
$saTableName = 'ipam'
$saCtx = (Get-AzStorageAccount | where {$_.StorageAccountName -eq $storageAccount}).Context
$saTable = (Get-AzStorageTable –Name $saTableName –Context $saCtx).CloudTable

$unmanagedAddresses = 0
$query = 'resourcecontainers
| where type == "microsoft.resources/subscriptions"'

#$subs = Search-AzGraph -Query $query

$subs = Get-AzSubscription -TenantId 'cef99625-c8ab-4a7b-baa2-3dd4811009be'
Write-Host "TIMB7: " $subs.count
foreach ($sub in $subs) {
    Set-AzContext -Subscription $sub.Id
    Write-Host "TIMB6: " $sub.Name
    foreach ($ipamRow in Get-AzTableRow -Table $saTable) {
        $na = $ipamRow.NetworkAddress
        Write-Host "TIMB2: " $na
        $vnet = Get-AzVirtualNetwork | where {$ipamRow.NetworkAddress -in $_.AddressSpace.AddressPrefixes}
        Write-Host "TIMB3:" $vnet
        if ($vnet -ne $null) {
            Write-Host "TIMB4: " $vnet.ResourceGroupName
            Write-Host "TIMB5: " $vnet.Name
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
$results = "Unmanaged address ranges found: " + $unmanagedAddresses

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $results
})
