$global:aadcfg = Get-Content ".\config.json" | ConvertFrom-Json
$Modell = "TravelMate Spin B118-G2-RN"
function Get-AuthToken {
    $clientId = $aadcfg.ClientID
    $tenantId = $aadcfg.TenantID
    $clientSecret = $aadcfg.ClientSecret
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }
    $reqTime = (Get-Date).ToUniversalTime()
    $tokenRequest = Invoke-RestMethod -Method Post -Uri $uri -Body $body
    $ExpiresOn = $reqTime.AddSeconds($tokenRequest.expires_in)
    if ($tokenRequest.access_token) {
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer " + $tokenRequest.access_token
            'ExpiresOn'     = $ExpiresOn
        }
        return $authHeader
    }
    else {
        return "Failed to get authToken"
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
    return $Output
}
$authToken = Get-AuthToken
$allAPDevices = Get-GraphData -authToken $authToken -uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities"
$allSelectedAPDevices = $allAPDevices | Where-Object { $_.model -like $Modell }
foreach ($device in $allSelectedAPDevices) {
    Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($device.id)" -Method Delete -Headers $authToken
    if ($device.managedDeviceId -ne "00000000-0000-0000-0000-000000000000") {
        Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.managedDeviceId)" -Method Delete -Headers $authToken
    }
    #Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/devices/$($device.azureAdDeviceId)" -Method Delete -Headers $authToken
}
$allIntuneDevices = Get-GraphData -authToken $authToken -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
$allSelectedIntuneDevices = $allIntuneDevices | Where-Object { $_.model -like $Modell }
foreach ($device in $allSelectedIntuneDevices) {
    Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.id)" -Method Delete -Headers $authToken
}
$allAADDevices = Get-GraphData -authToken $authToken -uri "https://graph.microsoft.com/beta/devices"
$allSelectedAADDevices = $allAADDevices | Where-Object { $_.model -like $Modell }
foreach ($device in $allSelectedAADDevices) {
    Remove-MsolDevice -ObjectId $device.id -Confirm:$false -Force
    #Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/devices/$($device.id)" -Method Delete -Headers $authToken
}
