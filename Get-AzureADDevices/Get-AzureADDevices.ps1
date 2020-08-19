function Get-AzureADDevices {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$false)] $serialNumber,
        [Parameter(Mandatory=$false)] $authToken
    )
    $graphApiVersion = "beta"
    $Resource = "devices"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    $authToken = Get-AuthToken
    $allDevices = Get-GraphData -Uri $uri -authtoken $authToken
}