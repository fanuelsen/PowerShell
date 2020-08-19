function Get-AutoPilotDevice {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$false)] $serialNumber,
        [Parameter(Mandatory=$false)] $authToken
    )
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeviceIdentities"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    $allDevices = Get-GraphData -Uri $uri -authtoken $authToken
    if ($serialNumber)
        {        
            $specificDevice = $allDevices | Where-Object { $_.serialNumber -eq "$serialNumber" }
            Return $specificDevice
        }
    else
        {
            Return $allDevices
        }
}