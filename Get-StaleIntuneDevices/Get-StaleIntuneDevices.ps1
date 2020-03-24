. ./functions.ps1
$authToken = Get-DeviceToken
$outfile = "staledevices.csv"
$cutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-dd")
$staleDevices = Get-GraphData -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices?filter=managementAgent eq 'mdm' or managementAgent eq 'easMDM' and complianceState eq 'noncompliant' and managedDeviceOwnerType eq 'company' and operatingSystem eq 'Windows'" -authToken $authToken
$staleDevices | Select-Object -Property id,devicename,operatingsystem,userdisplayname,managementstate,enrolleddatetime,wiFiMacAddress,ownertype,serialnumber | Export-Csv $outfile