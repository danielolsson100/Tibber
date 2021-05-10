<#
# Tibber REST API with Powershell by Daniel Olsson - 2021-05-10
Reference https://developer.tibber.com/docs/reference
Logon above to get Personal token

.Notes GraphiQL queries is case sensitive, ie DAILY vs HOURLY

Usage:
Get-CustTibberEnergyData -PersonalToken "xxxx" -TimePerid 30 -TimeType DAILY -EnergyType consumption
#>

function Global:Get-CustTibberEnergyData{
    param
    (

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$PersonalToken,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [INT]$TimePeriod,

    [parameter(Mandatory=$true)]
    [ValidateSet('DAILY','HOURLY')]
    $TimeType = "DAILY",

    [parameter(Mandatory=$true)]
    [ValidateSet('consumption','production')]
    $EnergyType = "consumption"

    )

    # Common Static Entires
    $uri = "https://api.tibber.com/v1-beta/gql"

    # Functions
    function Get-CustTibberAuth($uri,$PersonalToken){
        $authHeader = @{
                    'Content-Type'='application/json'
                    'Authorization'="Bearer " + $PersonalToken
                    }
        Return $authHeader
    }
    $authHeader = Get-CustTibberAuth -uri $uri -PersonalToken $PersonalToken

    # Build GraphiQL query that Tibber API accepts as input.
    if($EnergyType -eq "consumption"){
        $QueryConsumptionTemplate = '{ "query": "{viewer {homes {consumption (resolution: <TimeType>, last: <TimePeriod>) {nodes {from to cost unitPrice consumption consumptionUnit }}}}}" }'
        $Body = $QueryConsumptionTemplate -replace [regex]::Escape('<TimeType>'), $TimeType
        $Body = $Body -replace [regex]::Escape('<TimePeriod>'), $TimePeriod
        $Response = Invoke-RestMethod -Method Post -uri $uri -Headers $authHeader -Body $Body -ContentType "application/json"
        $Consumption = $Response.data.viewer.homes.consumption.nodes
        return $Consumption
    
    }
    elseif($EnergyType -eq "production"){
        $QueryProductionTemplate = '{ "query": "{viewer {homes {production (resolution: <TimeType>, last: <TimePeriod>) {nodes {from to production unitPrice production productionUnit }}}}}" }'
        $Body = $QueryProductionTemplate -replace [regex]::Escape('<TimeType>'), $TimeType
        $Body = $Body -replace [regex]::Escape('<TimePeriod>'), $TimePeriod
        $Response = Invoke-RestMethod -Method Post -uri $uri -Headers $authHeader -Body $Body -ContentType "application/json"
        $Production = $Response.data.viewer.homes.production.nodes
        return $Production
    }
}
Write-Host Usage: Get-CustTibberEnergyData -PersonalToken "XXXXXX" -TimePeriod 24 -EnergyType consumption -TimeType HOURLY

