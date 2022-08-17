##BLOCK1

$User = ""
$UserGroup = ""

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

$authToken = Get-AuthToken -User $User
$Users = Get-GraphData -uri "https://graph.microsoft.com/beta/groups/$UserGroup/members" -authToken $authToken
##BLOCK1 END

##BLOCK2 IF SERIENUMMER
#MED SERIENUMMER
$toWipe = Get-Content ##INSERT FILE HERE
$devices = @()
foreach ($dev in $toWipe) {
    $devices += Get-GraphData -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=serialNumber eq '$dev'" -authToken $authToken
}

##BLOCK2 ELSE IF GRUPPE
#BASERT PÅ GRUPPE
$allDevices = Get-GraphData -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices" -authToken $authToken
$devices = @()
foreach ($user in $Users) {
    $devices += $allDevices | Where-Object { $_.userId -eq $user.id }
}
##END IF BLOCK2

##CONTROLBLOCK
#ANTALL
$devices.Count

#SERIENUMMER
$devices.serialNumber
##CONTROLBLOCK END

##ACTIONBLOCK
#FINALLY WIPE
foreach ($device in ($devices | Where-Object { $_.serialnumber -notlike "NXVG*" })) {
    Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.id)/wipe" -Method Post -Headers $authToken
}
##ACTIONBLOCK END
