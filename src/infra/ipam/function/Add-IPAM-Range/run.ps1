# Add-IPAM-Range
#
# This function adds a range of network addresses for assignment to an Azure virtual network (VNet)
#
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$nwRange = $Request.Query.NwRange
if (-not $nwRange) {
    $nwRange = $Request.Body.InputObject.NwRange
}
$nwNumber = $Request.Query.NwNumber
if (-not $nwNumber) {
    $nwNumber = $Request.Body.InputObject.NwNumber
}
$nwSize = $Request.Query.NwSize
if (-not $nwSize) {
    $nwSize = $Request.Body.InputObject.NwSize
}
$nwEnvironment = $Request.Query.NwEnvironment
if (-not $nwEnvironment) {
    $nwEnvironment = $Request.Body.InputObject.NwEnvironment
}
$nwRegion = $Request.Query.NwRegion
if (-not $nwRegion) {
    $nwRegion = $Request.Body.InputObject.NwRegion
}

# Add records to an Azure storage table (storage account name is an application setting configured during function deployment)
$storageAccount = $env:ipamStorageAccount
$saTableName = 'ipam'
$saCtx = (Get-AzStorageAccount | where {$_.StorageAccountName -eq $storageAccount}).Context
$saTable = (Get-AzStorageTable –Name $saTableName –Context $saCtx).CloudTable
$tablePartKey = "IPAM"

switch ($nwSize) {
    "Small" {$count = 2; $suffix = '/23'}
    "Medium" {$count = 4; $suffix = '/22'}
    "Large" {$count = 8; $suffix = '/21'}
    Default {$count = 2; $suffix = '/23'}
}
$a,$b,$c,$d = $nwRange.Split(".")
for ($i = 0; $i -lt $nwNumber; $i++) {
    $rowKey = $(New-Guid).Guid
    $nwPrefix = "$a.$b.$([int]$c+($count * $i)).$d"
    $nwAddress = $nwPrefix + $suffix
    Write-Output "Adding network $nwAddress in the $nwEnvironment environment"
    $tableRow = Get-AzTableRow -Table $saTable | where {$_.NetworkAddress -eq $nwAddress}
    If ($tableRow -eq $null) {
        Add-AzTableRow -Table $saTable -PartitionKey $tablePartKey -RowKey ($rowKey) -Property @{"NetworkAddress"="$nwAddress";"Environment"="$nwEnvironment";"Region"="$nwRegion";"Allocated"=$false;"Notes"="";"Subscription"="$null";"ResourceGroup"="$null";"VNetName"="$null"}
    }
}

# Report all records
$results = Get-AzTableRow -table $saTable | select NetworkAddress, Region, Environment, Allocated | sort NetworkAddress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $results
})
