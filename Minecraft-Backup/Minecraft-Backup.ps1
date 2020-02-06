$DomainName = "YourDomainHere" #For cloud only, use AzureAD
$Username = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty Username
$Username = $Username.Replace("$DomainName\", "")

$Source = Get-ChildItem "C:\Users\$Username\AppData\Local\Packages\Microsoft.MinecraftEducationEdition_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftWorlds"
$Target = "C:\Backup"
If(!(Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force
}

foreach ($Dir in $Source) {
    Compress-Archive -Path $dir.fullname -DestinationPath "$Target\$Dir-$Date.zip"
}
