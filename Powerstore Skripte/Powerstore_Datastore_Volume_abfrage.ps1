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


# API Dell Powerstore https://10.82.100.194/swaggerui

Install-Module -Name Dell.PowerStore -Scope AllUsers

Import-Module -Name Dell.PowerStore

# Hier werden die Anmeldedaten in einen Secure String umgewandelt
$Username = "admin"
$Pass = ConvertTo-SecureString 'BY2#sQq!E0Cmn_bY4g#GCelHn1VwXxKsn' -asplaintext -force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Pass)

#Verbindung aufbauen zum Powerstore Cluste.
Connect-Cluster  -HostName 10.82.100.194 -IgnoreCertErrors -Credential $Cred

#Hier wird Cluster in eine Varibale gepackt.
$cluster = Get-Cluster

#Hier wird Das abzufragende Vloume abgefragt.
$Datastores = "HAM_Volume01_TEN", "HAM_Volume02_VDV", "HAM_Volume03_VDV"

#Hier wird das Cluster in eine Varibal gepackt.
$Volume = Get-Volume -Cluster $cluster -Name $Datastores #| fl Name, Size


# Mit der Funtion wird Definiert wie Bytes in TiB umgewandelt werden. 
function Convert-BytesToTebibytes ($bytes) {
    $Gigabytes = $bytes / 1GB
    return $Gigabytes
}

# Hier werden die Variablen befüllt für die Umrechnung benötigt werden
foreach ($Datastores in $Datastores){
    $Volume    = Get-Volume -Cluster $cluster -Name $Datastores
    $bytes     = $Volume.size
    $Gigabytes = Convert-BytesToTebibytes -bytes $bytes

    Write-Host "Volume Name: $Datastores"
    Write-Host "Bytes: $bytes"
    Write-Host "Gigabytes: $Gigabytes"
    
}

#Ausgabe der Größe in GB
Write-Output "Volume Name: $Datastores"
Write-Output "Bytes: $bytes"
Write-Output "Gigabytes: $Gigabytes"

# Disconect von der Powerstore
Disconnect-Cluster -HostName 10.82.100.194 -Confirm 