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

# Importieren Sie das VMware PowerCLI-Modul
#Import-Module VMware.PowerCLI

# Import-Module VMware.VimAutomation.Core

$vCenterServerIP = "vcenter01.intern.ten-it.de"

# Verbindung zum vCenter Server
$Username = "administrator@vsphere.local"
$Pass = ConvertTo-SecureString 'XCRPwTFM6$HZnFNf4BO"' -asplaintext -force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Pass)
Connect-VIServer -Server $vCenterServerIP -Credential $Cred

# Geben Sie die Namen der Datastores an, die Sie überprüfen möchten
$datastoreNames = "PPUG-Datastore01", "GreicheIP-Datastore01"

# Durchlaufen Sie jeden Datastore in der Liste
foreach ($datastoreName in $datastoreNames) {
    # Abrufen des Datastores
    $datastore = Get-Datastore -Name $datastoreName

    # Überprüfen, ob der Datastore existiert
    if ($datastore -ne $null) {
        # Speichern der Datastore-Informationen in einer Variable
        $datastoreInfo = $datastore | Format-Table -AutoSize

        # Speichern des zugewiesenen Speichers in einer Variable
        $allocatedSpace = $datastore.ExtensionData.Summary.Capacity

        # Speichern der Ausgaben in separaten Variablen
        Set-Variable -Name "${datastoreName}_Info" -Value $datastoreInfo
        Set-Variable -Name "${datastoreName}_AllocatedSpace" -Value $allocatedSpace
    } else {
        Set-Variable -Name "${datastoreName}_NotFound" -Value "Datastore $datastoreName wurde nicht gefunden."
    }
}

# Hier wird eine Function erstellt die dazu genutzt wird um Bytes in Gib umzurechnen. 
function Convert-BytesToTebibytes ($bytes) {
    $Gigabytes = $bytes / 1GB
    return $Gigabytes
}
# Umrechnen der Byte von Greiche in GiB.
$Greiche = Get-Variable -Name "*GreicheIP-Datastore01_AllocatedSpace", "*_Value", "*_NotFound"
$Greich_Bytes = $Greiche.Value
$Greiche_gb = Convert-BytesToTebibytes -bytes $Greich_Bytes

# Umrechnen der Byte von PPUG in GiB.
$PPUG = Get-Variable -Name "*PPUG-Datastore01_AllocatedSpace", "*_Value", "*_NotFound"
$PPUG_Bytes = $PPUG.Value
$PPUG_gb = Convert-BytesToTebibytes -bytes $PPUG_Bytes

# Ausgabe für die Powershell
Write-host -ForegroundColor green "Greiche IP: $Greiche_gb GB"
Write-host -ForegroundColor green "PPUG: $PPUG_gb GB"

# Ausgabe für Ninja der Daten von Greiche Feldname: Greiche IP Cloud Speicher

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set greicheCloudSpeicher "$Greiche_gb GB"

# Ausgabe für Ninja der Daten von PPUG Feldname: PPUG Cloud Speicher

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ppugCloudSpeicher "$PPUG_gb GB"

