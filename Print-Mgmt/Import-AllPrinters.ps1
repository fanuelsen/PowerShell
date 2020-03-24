$CsvFile = ""
$PrinterList = Import-Csv $CsvFile -Delimiter ","
$PrintDriver = ""
$PrintServer = ""

foreach ($Printer in $PrinterList) {
    Add-PrinterPort -ComputerName $PrintServer -Name $Printer.PortName -PrinterHostAddress $Printer.IPAddress
    Add-Printer -ComputerName $PrintServer -Name $Printer.Serial -PortName $Printer.PortName -Comment $Printer.Comment -Location $Printer.Location -DriverName $PrintDriver
}