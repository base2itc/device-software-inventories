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


$vCenterServerIP = "BGD-VCSA01.tn.impuls-reha.de"
$FirmenName = "BGD*"

function Get-VMinformation(
        [parameter(mandatory)] [string] $vCenterServerIP,
        [parameter(mandatory)] [string] $FirmenName
    ) 
{

# Verbindung zum vCenter Server

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$Username = "administrator@vsphere.local"
$Pass = ConvertTo-SecureString '@St|?agfRd?4y' -asplaintext -force
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
##AP'I Call für das Costum field der RDS User abfrage.
$body = @{
    grant_type = "client_credentials"
    client_id = "cbr0wXRfP36tMoPxn4vHugDcIjo"
    client_secret = "feHijh-HBKkVNQdsWZtq5N8xBGIesU0sDtuKNAS-C9AoPTl5Pjpp7A"
    redirect_uri = "https://localhost"
    scope = "monitoring"
}
#API Headers
$API_AuthHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$API_AuthHeaders.Add("accept", 'application/json')
$API_AuthHeaders.Add("Content-Type", 'application/x-www-form-urlencoded')

# API Token
$auth_token = Invoke-RestMethod -Uri https://eu.ninjarmm.com/oauth/token -Method POST -Headers $API_AuthHeaders -Body $body
$access_token = $auth_token | Select-Object -ExpandProperty 'access_token' -EA 0

# Headres Befüllen
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", 'application/json')
$headers.Add("Authorization", "Bearer $access_token")

$devices_url = "https://eu.ninjarmm.com/v2/devices"
$devices = Invoke-RestMethod -Uri $devices_url -Method GET -Headers $headers
# Array um die Divice ID zu ermitteln
$i = 0
$output = 0
foreach($device in $devices){
    if($device.dnsName -match "BGD-AD01.tn.impuls-reha.de"){
        $output = $device.id
   }       
}
$output
# Auslesen der ustom Fields
$custom_fields_url = "https://eu.ninjarmm.com/v2/device/$output/custom-fields"
$custom_field = Invoke-RestMethod -Uri $custom_fields_url -Method GET -Headers $headers        
$rdsuserBgdTN = $custom_field.rdsuserBgdTN

#$custom_field = Invoke-RestMethod -Uri $custom_fields_url -Method GET -Headers $headers

##########################################################################################################################################################################################

# Print Information for each Virtual Machine
Write-Host "VM Name: $vmName, CPU: $cpuCount, RAM: $memoryGB GB, Storage: $storageGB GB", $rdsuserBgdTN "RDS-User"
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set greicheCloudUmgebung  $Cloudvms "VMs," $CloudCPU "CPUs," $CloudRam "GB RAM," $CloudStorage "StorageGB,", $rdsuserBgdTN "RDS-User"
 

# Benden der verbindung zum vCenter Server
Disconnect-VIServer -Server $vCenterServerIP -Confirm:$false
}

Get-VMinformation -vCenterServerIP $vCenterServerIP -FirmenName $FirmenName