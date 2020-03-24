. ./functions.ps1
$authToken = Get-DeviceToken
$devicesWithErrors = Get-GraphData -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=complianceState eq 'noncompliant' and ownerType eq 'company' and deviceType eq 'windowsRT'&`$select=id" -authToken $authToken

foreach ($device in $devicesWithErrors) {
    Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($device.id)')/syncDevice" -Method Post -Headers $authToken
}