function Add-AutoPilotImportedDevice {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)] $serialNumber,
        [Parameter(Mandatory = $true)] $hardwareIdentifier,
        [Parameter(Mandatory = $false)] $orderIdentifier = "",
        [Parameter(Mandatory = $false)] $groupTag = "",
        [Parameter(Mandatory = $false)] $productKey = ""
    )
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/importedWindowsAutopilotDeviceIdentities"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    $json = New-Object psobject -Property @{
        "@odata.type"        = "#microsoft.graph.importedWindowsAutopilotDeviceIdentity"
        "orderIdentifier"    = "$orderIdentifier"
        "groupTag"           = "$groupTag"
        "serialNumber"       = "$serialNumber"
        "productKey"         = "$productKey"
        "hardwareIdentifier" = "$hardwareIdentifier"
        "state"              = @{
            "@odata.type"          = "microsoft.graph.importedWindowsAutopilotDeviceIdentityState"
            "deviceImportStatus"   = "pending"
            "deviceRegistrationId" = ""
            "deviceErrorCode"      = 0
            "deviceErrorName"      = ""
        }
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
        #return $json
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}

function Import-AutoPilotCSV {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)] $csvFile,
        [Parameter(Mandatory = $false)] $orderIdentifier = "",
        [Parameter(Mandatory = $false)] $groupTag = ""
    )
    $devices = Import-Csv $csvFile
    foreach ($device in $devices) {
        if ($orderIdentifier -ne "") {
            $o = $orderIdentifier
        }
        else {
            $o = $device.'OrderID'
        }
        if ($groupTag -ne "") {
            $g = $groupTag
        }
        else {
            $g = $device.'Group Tag'
        }
        Add-AutoPilotImportedDevice -serialNumber $device.'Device Serial Number' -hardwareIdentifier $device.'Hardware Hash' -orderIdentifier $o -groupTag $g -productKey $device.'Windows Product ID'
    }
}