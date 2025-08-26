 ######   #######  ##   ##            ####    ######              ####            ###      ##   ##
 # ## #    ##   #  ###  ##             ##     # ## #             ##  ##            ##      ##   ##
   ##      ## #    #### ##             ##       ##              ##       ##  ##    ##      ##   ##
   ##      ####    ## ####             ##       ##              ##       #######   #####   #######
   ##      ## #    ##  ###             ##       ##              ##  ###  ## # ##   ##  ##  ##   ##
   ##      ##   #  ##   ##             ##       ##               ##  ##  ##   ##   ##  ##  ##   ##
  ####    #######  ##   ##            ####     ####               #####  ##   ##  ######   ##   ##
# -----------------------------------------------------------
# Dieses Skript wurde erstellt von: Philipp von Kirchner
# Unternehmen: TEN IT GmbH
# -----------------------------------------------------------

$vCenterServerIP = "vcsa01.impulsreha.local"
$FirmenName = "Mitarbeiter*"

function Get-VMinformation(
        [parameter(mandatory)] [string] $vCenterServerIP,
        [parameter(mandatory)] [string] $FirmenName
    ) 
{

# Verbindung zum vCenter Server
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$Username = "administrator@vsphere.local"
$Pass = ConvertTo-SecureString '0KRpD6LKWlUs!s9zSB6r' -asplaintext -force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Pass)
Connect-VIServer -Server $vCenterServerIP -Credential $Cred

# Variablen für das zusammenrechnen der Werte.
$vmList = Get-VM -Name $FirmenName*
$Cloudvms     = 0
$CloudCPU     = 0
$CloudRam     = 0
$CloudStorage = 0
# Schleife die jede VM abgfragt die mit dem Firmenname beginnt und die werte CPU, RAM und Speicher in GB ausgeben. 
foreach ($vm in $vmList) {
     $vmName = $vm.Name
     $cpuCount = $vm.NumCpu
     $memoryGB = [math]::Round($vm.MemoryGB, 2)
     $storageGB = [math]::Round(($vm.ProvisionedSpaceGB))
     $Cloudvms++
     $CloudCPU += $cpuCount
     $CloudRam += $memoryGB
     $CloudStorage += $storageGB
     
     Write-Host "VM Name: $vmName, CPU: $cpuCount, RAM: $memoryGB GB, Storage: $storageGB GB"
 }




##########################################################################################################################################################################################
# Ausgabe für jede VM

Write-Host "$Cloudvms "VMs," $CloudCPU "CPUs," $CloudRam "GB RAM," $CloudStorage "StorageGB,""
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set BergedorferMAUmgebung  $Cloudvms "VMs," $CloudCPU "CPUs," $CloudRam "GB RAM," $CloudStorage "StorageGB,"

# Benden der verbindung zum vCenter Serve
Disconnect-VIServer -Server $vCenterServerIP -Confirm:$false
}

#Aufrufen der Funktion. 
Get-VMinformation -vCenterServerIP $vCenterServerIP -FirmenName $FirmenName
