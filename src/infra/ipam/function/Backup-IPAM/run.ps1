# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

Import-Module Az.Storage

Connect-AzAccount -Identity

# App Setting Parameters
$storageAccountName = $env:ipamStorageAccount
Write-Host $StorageAccountName

# Generating Account Key & Creating Context 
$key = (Get-AzStorageAccount| where {$_.StorageAccountName -eq $storageAccountName} | Get-AzStorageAccountKey)[0].Value
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key

# Gather table names in the storage account
$tables = (Get-AzStorageTable –Context $context).CloudTable | Select-Object Name -ExpandProperty Name

# AzCopy backup
foreach ($table in $tables) {
    Write-Host "Table found: $table"
    $source = "https://$storageAccountName.table.core.windows.net/$table"
    Write-Host "URL generated: $source"
    C:\home\site\wwwroot\Backup-IPAM\AzCopy.exe  /Source:$source /dest:Backup-IPAM\$table-backup /sourceKey:$key /PayloadFormat:CSV --overwrite
#    C:\home\site\wwwroot\Backup-IPAM\AzCopy.exe  /Source:$source /dest:"C:\home\site\wwwroot\Backup-IPAM\$table-backup" /sourceKey:$key /PayloadFormat:CSV
}
