$CsvFile = ""
$PrintNames = ""
$PrintServer = ""
Get-Printer -ComputerName $PrintServer -Name $PrintNames | Select-Object -Property Comment,Location,Name,PortName | Export-Csv $CsvFile -Encoding utf8