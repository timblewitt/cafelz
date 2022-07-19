#
#### This script calls the LZIM Azure Function App (Add-LzId function) using the REST API to add a range of
#### Azure Landing Zone identifiers for a given environment (e.g. production/test/dev/staging/QA).
#### These ids can then be requested individually using the Get-LzId function for new Azure Landing Zones.
#
function Add-Ipam-Records {
    param (
        $nwRange,
        $nwNumber,
        $nwSize,
        $nwEnvironment,
        $nwRegion
    )
    $faName = 'fa-mp0004-uks-ipam'
    $faRg = 'rg-mp0004-uks-ipam'     
    $faId = (Get-AzWebApp -Name $faName -ResourceGroupName $faRg).Id 
    $faFunction = 'Add-Network-Address'
    $faFunctionKey = (Invoke-AzResourceAction -ResourceId "$faId/functions/$faFunction" -Action listkeys -Force).default
    $uri = 'https://' + $faName + '.azurewebsites.net/api/' + $faFunction + '?code=' + $faFunctionKey
    $body = @{
        'InputObject' = @{
            'NwRange' = $nwRange
            'NwNumber' = $nwNumber
            'NwSize' = $nwSize
            'NwEnviroment' = $nwEnvironment
            'NwRegion' = $nwRegion
        }
    } | ConvertTo-Json 
    $params = @{
        'Uri'         = $uri
        'Method'      = 'POST'
        'ContentType' = 'application/json'
        'Body'        = $body
    }
    Invoke-RestMethod @params      
}

Add-Ipam-Records -nwRange '10.160.0.0' -nwNumber 4 -nwSize 'Small' -nwEnvironment 'Prod' -nwRegion 'uksouth'


#@("10.160.0.0",4,"Small","Prod","uksouth"),
#@("10.161.0.0",4,"Medium","Prod","uksouth"),
#@("10.162.0.0",4,"Large","Prod","uksouth"),
#@("10.170.0.0",4,"Small","Nonprod","uksouth"),
#@("10.171.0.0",4,"Medium","Nonprod","uksouth"),
#@("10.172.0.0",4,"Large","Nonprod","uksouth"),
#@("10.180.0.0",4,"Small","Prod","ukwest"),
#@("10.181.0.0",4,"Medium","Prod","ukwest"),
#@("10.182.0.0",4,"Large","Prod","ukwest"),
#@("10.190.0.0",4,"Small","Nonprod","ukwest"),
#@("10.191.0.0",4,"Medium","Nonprod","ukwest"),
#@("10.192.0.0",4,"Large","Nonprod","ukwest")
