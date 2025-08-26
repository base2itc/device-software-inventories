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

# Importieren des Exchange-Moduls
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction SilentlyContinue

# Servername
$server = "Server12.impulsreha.local"

# Dienste und Komponenten, die ignoriert werden sollen
$ignoredServices = @('MSExchangePop3', 'MSExchangePOP3BE', 'vmickvpexchange', 'wsbexchange')
$ignoredComponents = @('ForwardSyncDaemon', 'ProvisioningRps')

# Initialisierung der Status- und Fehler-Variablen
$serviceStatus = $componentStatus = $mapiStatus = $pfStatus = $dbStatus = "OK"
$serviceError = $componentError = $mapiError = $pfError = $dbError = ""

# Service Check
Write-Host "Service Check:"
$services = Get-Service -ComputerName $server | Where-Object { $_.name -like "*exchange*" -and $ignoredServices -notcontains $_.name }
foreach ($service in $services) {
    if ($service.Status -ne 'Running') {
        $serviceStatus = "Fehler"
        $serviceError = "Fehler bei $($service.name)"
        break
    }
}

# Get-ServerComponentState
Write-Host "`nGet-ServerComponentState:"
$components = Get-ServerComponentState $server | Where-Object { $ignoredComponents -notcontains $_.Component }
foreach ($component in $components) {
    if ($component.State -ne 'Active') {
        $componentStatus = "Fehler"
        $componentError = "Fehler bei $($component.Component)"
        break
    }
}

# MAPI Connectivity
Write-Host "`nMAPI Connectivity:"
$mapi = Test-MAPIConnectivity -Server $server
if ($mapi.Result.Value -ne "Success") {
    $mapiStatus = "Fehler"
    $mapiError = "Fehler bei MAPI Connectivity"
}

# Public Folder
Write-Host "`nPublic Folder:"
$pf = Get-PublicFolder -Recurse -ResultSize Unlimited
if (!$pf) {
    $pfStatus = "Fehler"
    $pfError = "Fehler bei Public Folder"
}

# Mailbox Database Copy State
Write-Host "`nMailbox Database Copy State:"
$dbs = Get-MailboxDatabaseCopyStatus -Server $server
foreach ($db in $dbs) {
    if ($db.Status -ne 'ServiceDown') {
        $dbStatus = "Fehler"
        $dbError = "Fehler bei $($db.Identity)"
        break
    }
}

# Speichern der Ausgabe in Variablen
$serviceCheckAusgabe = "`nService Check Status: $serviceStatus"
if ($serviceError) { $serviceCheckAusgabe += "`nService Check Fehler: $serviceError" }

$serverComponentStateAusgabe = "`nGet-ServerComponentState Status: $componentStatus"
if ($componentError) { $serverComponentStateAusgabe += "`nGet-ServerComponentState Fehler: $componentError" }

$mapiConnectivityAusgabe = "`nMAPI Connectivity Status: $mapiStatus"
if ($mapiError) { $mapiConnectivityAusgabe += "`nMAPI Connectivity Fehler: $mapiError" }

$publicFolderAusgabe = "`nPublic Folder Status: $pfStatus"
if ($pfError) { $publicFolderAusgabe += "`nPublic Folder Fehler: $pfError" }

$mailboxDatabaseCopyStateAusgabe = "`nMailbox Database Copy State Status: $dbStatus"
if ($dbError) { $mailboxDatabaseCopyStateAusgabe += "`nMailbox Database Copy State Fehler: $dbError" }

# Ausgabe der Variablen
Write-Host "$serviceCheckAusgabe"
Write-Host "$serverComponentStateAusgabe"
Write-Host "$mapiConnectivityAusgabe"
Write-Host "$publicFolderAusgabe"
Write-Host "$mailboxDatabaseCopyStateAusgabe"


# Service Check
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangeServicecheck "$serviceCheckAusgabe"

# Get-ServerComponentState
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangeComponentState "$serverComponentStateAusgabe"

# MAPI Connectivity
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangeMAPIConnectivity "$mapiConnectivityAusgabe"

# Public Folder
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangePublicFolder "$publicFolderAusgabe"

# Mailbox Database Copy State
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangeMailboxDatabase "$mailboxDatabaseCopyStateAusgabe"
