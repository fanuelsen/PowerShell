# Scripts

| Name | Explanation |
| ---- | ---------- |
| Get-AllPrinters.ps1 | Generates a csv file with all or specified printqueues on specified server |
| Import-AllPrinters.ps1 | Imports printqueues from csv file |

# Get-AllPrinters.ps1
| Name | Explanation | Necessity |
| ---- | ---- | ---- |
| `$CsvFile` | Variable for generated file containing the output of all or specified queues | Optional 
| `$PrintQueues` | If you need to output specific queues. Use quotation marks sperated with comma to specify numerous queues. | Optional |  
| `$PrintServer` | DNS or IP for your printserver that contains your printqueues. | Required
|`Get-Printer -ComputerName $FromPrintServer -Name $PrintQueues` | Gets all print queues in the `$PrintQueues` variable from the printserver in the `$FromPrintServer` variable. If you want all queues on the server remove`-Name $PrintQueues` from the script. | Required |
| `Select-Object -Property Comment,Location,Name,PortName` | This section selects the properties you want to exctract from the queue. | Optional | 
| `Export-Csv $CsvFile -Encoding utf8` | Generates a comma delimited file with printqueues and properties at your disired location if specified in the `$CsvFile` variable. | Optional |


# Example Get-AllPrinters.ps1

```powershell
$CsvFile = "myprinters.csv"
$PrintNames = "printer1","printer2"
$FromPrintServer = "printerserver.domain"
Get-Printer -ComputerName $FromPrintServer -Name $PrintNames | Select-Object -Property Comment,Location,Name,PortName | Export-Csv $CsvFile -Encoding utf8
```

# Import-AllPrinters.ps1
| Name | Explanation | Necessity |
| ---- | ---- | ---- |
| `$CsvFile` | File conntaining the output of all (or) specified print queues | Required |
| `$PrinterList`| CSV file containing print queues with specific delimiter. | Required |
| `$PrintDriver`| The printdriver to be used when adding queues. | Optional |
| `$PrintServer`| The server to populate with print queues. | Required |
| `foreach ($Printer in $PrinterList)` | This loop cycles trough every queue in specified CSV file and adds them and the necessary printports. | Required |

# Example Import-AllPrinters.ps1

```powershell
$CSVfile = "myprinters.csv"
$PrinterList = Import-Csv $CsvFile -Delimiter ","
$PrintDriver = "My Best Universal Driver"
$PrintServer = "printserver.domain" 
foreach ($Printer in $PrinterList) {
    Add-PrinterPort -ComputerName $PrintServer -Name $Printer.PortName -PrinterHostAddress $Printer.IPAddress
    Add-Printer -ComputerName $PrintServer -Name $Printer.Name -PortName $Printer.PortName -Comment $Printer.Comment -Location $Printer.Location -DriverName $PrintDriver
}
```