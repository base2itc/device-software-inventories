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
# Erstellt am: 11.01.2024
# Bearbeitet am: 15.01.2024
# -----------------------------------------------------------

# Powerstore API URL, Benutzername und Passwort
$api_url = "https://10.82.100.194/api/rest/alert"
$username = "admin" # Hier Admin Konto hinterlegen
$password = 'BY2#sQq!E0Cmn_bY4g#GCelHn1VwXxKsn' # Passwort für den Admin

# Cred erstellen
$secPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $secPassword)

# Hier der der Header befüllt
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", 'application/json')

# Hier wird die API das erste mal abgefragt umd die Alarm IDs zu ermitteln.
$response = Invoke-RestMethod -Uri "$api_url" -SkipCertificateCheck  -Authentication Basic -Credential $credential -Method GET -Headers $headers #-Body $body

# Initialisieren des Arrays für aktive Alarme
$activeAlarms = @()

# Durchlauf von jedem Alarm
foreach ($alarm in $response) {
        # Hier wird jede ID überprüft und auf die gewünschten Variablen geprüft.
        $alarm_url = $api_url  + "/" + $alarm.id + "?select=state,severity,resource_name"
        $alarm_response = Invoke-RestMethod -Uri $alarm_url -Method Get -Headers $headers -ContentType "application/json" -SkipCertificateCheck -Credential $credential

    # Überprüfen des Status für jeden Alarm
    if ($alarm_response.state -eq "ACTIVE" -and $alarm_response.severity -eq "Minor" -or $alarm_response.severity -eq "Major" -or $alarm_response.severity -eq "Critical" ) {
        
        # Hier wird das Array befüllt
        $activeAlarms += $alarm_response
            } 
}
#Variablen die, die ausgabe aufnehmen so das sie Später im Skript genutzt werden kann.  
$Fehler = $null
$kein_Fehler = $null

# Überprüfen ob aktive Alarme vorhanden sind und wenn ja diese dann mit einer Gesonderten Massage ausgeben. 
if ($activeAlarms.Count -gt 0) {
        $activeAlarms
        $Fehler = Write-Output "Es sind Alarme auf der Powerstore vorhanden, diese bitte einmal prüfen:" $activeAlarms
  } else {
        $kein_Fehler = Write-Output "Es sind keine aktiven Alarme vorhanden."
}

# Ausgabe der Variablen für Fehler oder keine Fehler. 
Write-host -ForegroundColor Magenta $Fehler
Write-host -ForegroundColor Magenta $kein_Fehler

# Übergabe der Ausgabe an Ninja.
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set TEN_IT_Powerstore_PS01 $Fehler $kein_Fehler

