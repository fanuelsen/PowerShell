$global:cfg = Get-Content config.json | ConvertFrom-Json
function Get-DeviceToken {
    $clientId = $cfg.clientid
    $tenantId = $cfg.tenantid
    $preferredbrowser = "Microsoft Edge Canary" 
    $authurl = "https://login.microsoftonline.com/$tenantId"
    $resource = "https://graph.microsoft.com/"
    $postParams = @{ resource = "$resource"; client_id = "$clientId" }
    $response = Invoke-RestMethod -Method POST -Uri "$authurl/oauth2/devicecode" -Body $postParams
    Write-Host $response.message
    $code = ($response.message -split "code " | Select-Object -Last 1) -split " to authenticate." | pbcopy
    open https://microsoft.com/devicelogin -a $preferredbrowser 
    Pause
    $tokenParams = @{ grant_type = "device_code"; resource = "$resource"; client_id = "$clientId"; code = "$($response.device_code)" }
    $tokenResponse = Invoke-RestMethod -Method POST -Uri "$authurl/oauth2/token" -Body $tokenParams
    If ($null -eq $tokenResponse) {
        Write-Warning "Not Connected"
    }
    Else {
        Write-Host -ForegroundColor Green "Connected"
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer " + $tokenResponse.access_token
        }
        return $authHeader
    }
}
function Get-GraphData {
    Param (
        $uri,
        $authToken
    )
    $Response = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get)
    $Output = $Response.Value
    $NextLink = $Response."@odata.nextLink"
    while ($NextLink -ne $null) {
        $Response = (Invoke-RestMethod -Uri $NextLink -Headers $authToken -Method Get)
        $NextLink = $Response."@odata.nextLink"
        $Output += $Response.Value
    }
    if ($Output -eq $null) {
        $Output = $Response
    }
    return $Output
}
