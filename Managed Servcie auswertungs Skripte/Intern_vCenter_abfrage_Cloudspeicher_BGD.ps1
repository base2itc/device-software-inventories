 ######   #######  ##   ##            ####    ######              ####            ###      ##   ##
 # ## #    ##   #  ###  ##             ##     # ## #             ##  ##            ##      ##   ##
   ##      ## #    #### ##             ##       ##              ##       ##  ##    ##      ##   ##
   ##      ####    ## ####             ##       ##              ##       #######   #####   #######
   ##      ## #    ##  ###             ##       ##              ##  ###  ## # ##   ##  ##  ##   ##
   ##      ##   #  ##   ##             ##       ##               ##  ##  ##   ##   ##  ##  ##   ##
  ####    #######  ##   ##            ####     ####               #####  ##   ##  ######   ##   ##
# -----------------------------------------------------------
# Datum der Erstellung:
# Datum der Letzten bearbeitung:  
# Dieses Skript wurde erstellt von: Philipp von Kirchner
# Unternehmen: TEN IT GmbH
# -----------------------------------------------------------

# Importieren Sie das VMware PowerCLI-Modul
Import-Module VMware.PowerCLI -Global
Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction warn
# Hier wird da vcenter eingetragen das abgefragtwerden soll
$vCenterServerIP = "bgd-vcsa01.tn.impuls-reha.de"

# Verbindung zum vCenter Server
$Username = "administrator@vsphere.local"
$Pass = ConvertTo-SecureString '@St|?agfRd?4y' -asplaintext -force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Pass)
Connect-VIServer -Server $vCenterServerIP -Credential $Cred 

# Geben Sie die Namen der Datastores an, die Sie überprüfen möchten
$datastoreNames = "BGD-LUN01"

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
    $Gigabytes = $bytes/1GB
    return $Gigabytes
}
# Umrechnen der Byte von BGD GiB.
$BGD = Get-Variable -Name "*BGD-LUN01_AllocatedSpace", "*_Value"
$BGD_Bytes = $BGD.Value
$BGD_gb = Convert-BytesToTebibytes -bytes $BGD_Bytes


# Ausgabe für die Powershell
Write-host -ForegroundColor green "Greiche IP: $BGD_gb GB"

# Ausgabe für Ninja der Daten von Greiche Feldname: BGD Cloud Speicher

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set bgdCloudSpeicher "$BGDe_gb GB"



