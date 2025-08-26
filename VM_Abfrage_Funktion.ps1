# Param( [Parameter(Mandatory=$True)] [string]$vCenterServerIP )
# Param( [Parameter(Mandatory=$True)] [string]$FirmenName )
# Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


function Get-VMinformation(
        [parameter(mandatory)] [string] $vCenterServerIP,
        [parameter(mandatory)] [string] $FirmenName
    ) 
  #  {

# Prüfen ob das PowerShell VMware.PowerCLI Module Installiert ist.

# Write-Host "Prüfen ob das Modul VMware.PowerCLI ..." -ForegroundColor DarkYellow

# if (!(Get-Module -ListAvailable -Name "VMware.PowerCLI")) {

  #  Write-Host "VMware.powerCLI ist nicht Insttaliert. Installation gestartet..." -ForegroundColor DarkYellow

   # Install-Module VMware.PowerCLI -Scope CurrentUser -Force

 #}
{
# Import vSphere PowerCLI Module
Import-Module VMware.PowerCLI


# Verbindung zum vCenter Server
Connect-VIServer -Server $vCenterServerIP

$vmList = Get-VM -Name $FirmenName*

# Schleife die jede VM abgfragt die mit dem Firmenname beginnt und die werte CPU, RAM und Speicher in GB ausgeben. 
foreach ($vm in $vmList) {
     $vmName = $vm.Name
     $cpuCount = $vm.NumCpu
     $memoryGB = [math]::Round($vm.MemoryGB, 2)
     $storageGB = [math]::Round(($vm.ProvisionedSpaceGB))

# Print Information for each Virtual Machine
     Write-Host "VM Name: $vmName, CPU: $cpuCount, RAM: $memoryGB GB, Storage: $storageGB GB"
 }

# Benden der verbindung zum vCenter Server
Disconnect-VIServer -Server $vCenterServerIP -Confirm:$false
}

