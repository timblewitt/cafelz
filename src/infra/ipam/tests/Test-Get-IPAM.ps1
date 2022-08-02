#
##### This script calls the LZIM function app using the REST API to retrieve a free
##### Azure Landing Zone identifier for a given environment.
#
function Get-Ipam-Record {
    param (
        $Environment,
        $Region,
        $NetworkSize,
        $Notes
    )                
    $faName = 'fa-np0004-uks-ipam'
    $faRg = 'rg-np0004-uks-ipam'     
    $faId = (Get-AzWebApp -Name $faName -ResourceGroupName $faRg).Id 
    $faFunction = 'Get-IPAM-Address'
    $faFunctionKey = (Invoke-AzResourceAction -ResourceId "$faId/functions/$faFunction" -Action listkeys -Force).default
    $uri = 'https://' + $faName + '.azurewebsites.net/api/' + $faFunction + '?code=' + $faFunctionKey
    $body = @{
        'InputObject' = @{
            'NwEnvironment' = $Environment
            'NwRegion' = $Region
            'NwSize' = $NetworkSize
            'NwNotes' = $Notes
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

Get-Ipam-Record -Environment 'Nonprod' -Region 'uksouth' -NetworkSize 'Large' -Notes 'Test addition'
