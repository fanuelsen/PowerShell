$DomainName = "AzureAD"
$Username = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty Username
$Username = $Username.Replace("$DomainName\", "")
$Date = Get-Date -Format "dd-MM-yyyy"
$MinecraftAppDir = Get-ChildItem C:\Users\$Username\AppData\Local\Packages\ -recurse | Where-Object { $_.Name -match "Microsoft.MinecraftEducation" }
$MinecraftWorldDir = Get-ChildItem $MinecraftAppDir.FullName -recurse | Where-Object { $_.Name -match "minecraftWorlds" }
$Source = Get-ChildItem $MinecraftWorldDir.Fullname
$Target = "C:\Backup"

If(!(Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force
}

foreach ($Dir in $Source) {
    Compress-Archive -Path $Dir.FullName -DestinationPath "$Target\$Dir-$Date.zip" -Force
}
