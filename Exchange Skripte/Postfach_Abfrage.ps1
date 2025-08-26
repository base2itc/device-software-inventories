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

# Definieren der Größe in Bytes (20 GB)
$sizeLimit = 20 * 1024 * 1024 * 1024

# Abrufen der Mitglieder der Gruppe
$groupMembers = Get-DistributionGroupMember -Identity "01BI_GmbH"

# Abrufen aller Postfächer der Gruppenmitglieder, die größer als 20 GB sind
$mailboxes = $groupMembers | Get-Mailbox | Get-MailboxStatistics | Where-Object {$_.TotalItemSize.Value.ToBytes() -gt $sizeLimit}

# Überprüfen, ob Postfächer gefunden wurden
if ($mailboxes) {
    # Speichern der Postfachdetails in einer Variable
    $mailboxDetails = $mailboxes | Format-Table DisplayName, TotalItemSize
} else {
    # Speichern der Meldung in einer Variable
    $message = "Alle Postfächer OK"
}
 Write-Host -ForegroundColor Green $message
 Write-Host -ForegroundColor Green $mailboxDetails
  

 #Benutzerdefiniertes Feld für Ninja
 C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ExchangeMailboxUebersicht "$mailboxDetails $message"