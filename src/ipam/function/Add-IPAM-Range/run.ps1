using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
######## Get the environment (e.g. production/test/dev/staging/QA) and the number of ids to add to the table for that environment
$nwRange = $Request.Query.NwRange
if (-not $nwRange) {
    $nwRange = $Request.Body.NwRange
}
$nwNumber = $Request.Query.NwNumber
if (-not $nwNumber) {
    $nwNumber = $Request.Body.NwNumber
}
$nwSize = $Request.Query.NwSize
if (-not $nwSize) {
    $nwSize = $Request.Body.NwSize
}
$nwEnvironment = $Request.Query.NwEnvironment
if (-not $nwEnvironment) {
    $nwEnvironment = $Request.Body.NwEnvironment
}
$nwRegion = $Request.Query.NwRegion
if (-not $nwRegion) {
    $nwRegion = $Request.Body.NwRegion
}

# Add LZ IDs to Azure storage table (storage account name is an application setting configured during function deployment)
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
    $nwAddress="$a.$b.$([int]$c+($count * $i)).$d" + $suffix
    $nwEnv = $nwEnvironment
    $nwRegion = $nwRegion
    Write-Output "Adding network $nwAddress in the $nwEnv environment"

    Add-AzTableRow `
    -table $saTable `
    -partitionKey $tablePartKey `
    -rowKey ($rowKey) -property @{"NetworkAddress"="$nwAddress";"Environment"="$nwEnvironment";"Region"="$nwRegion";"Allocated"=$false;"Notes"="";"Subscription"="$null";"ResourceGroup"="$null";"VNetName"="$null"}
}

$results = Get-AzTableRow -table $saTable | select NetworkAddress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $results
})
