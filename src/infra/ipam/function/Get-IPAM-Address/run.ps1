# Get-IPAM-Address
#
# This function returns a free network address range for an Azure virtual network (VNet)
#
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$nwEnvironment = $Request.Query.NwEnvironment
if (-not $nwEnvironment) {
    $nwEnvironment = $Request.Body.InputObject.NwEnvironment
}
$nwRegion = $Request.Query.NwRegion
if (-not $nwRegion) {
    $nwRegion = $Request.Body.InputObject.NwRegion
}
$nwSize = $Request.Query.NwSize
if (-not $nwSize) {
    $nwSize = $Request.Body.InputObject.NwSize
}
$nwNotes = $Request.Query.NwNotes
if (-not $nwNotes) {
    $nwNotes = $Request.Body.InputObject.NwNotes
}
switch ($nwSize) {
    "Small" {$nwSuffix = '23'}
    "Medium" {$nwSuffix = '22'}
    "Large" {$nwSuffix = '21'}
    Default {$nwSuffix = '23'}
}

# Get next free record (Allocated = false) in Azure Storage table for requested parameters.
# The storage account name is an application setting configured during function deployment.
$storageAccount = $env:ipamStorageAccount
$saTableName = 'ipam'
$saCtx = (Get-AzStorageAccount | where {$_.StorageAccountName -eq $storageAccount}).Context
$saTable = (Get-AzStorageTable –Name $saTableName –Context $saCtx).CloudTable

$freeIpam = Get-AzTableRow -table $saTable | where {($_.Environment -eq $nwEnvironment) -and ($_.Region -eq $nwRegion) -and ($_.Allocated -eq $false) -and ((($_.NetworkAddress).Split("/")[1]) -eq $nwSuffix)} | select -First 1 
If ($freeIpam -ne $null) {
    $freeIpam.Allocated = $true
    $freeIpam.Notes = $nwNotes
    $freeIpam | Update-AzTableRow -Table $saTable 
    $results = $freeIpam.NetworkAddress 
}
Else {
    $results = "IPAM ERROR: No free network addresses for the $nwEnvironment environment in $nwRegion with a $nwSize network"
    Write-Host $results
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $results
})
