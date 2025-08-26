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
# Erstellt am 05.01.2024
# -----------------------------------------------------------

#Hier wird der Zertifikatsfehler ignoriert und das TLS protcol auf 1.2 getsellt 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Mailstore API URL, Benutzername und Passwort
$api_url = "https://#FQDN eintarge des Servers#:8463/api/invoke/GetWorkerResults/"
$username = "Username" # Hier Admin Konto hinterlegen
$password = 'Password' # Passwort für den Admin

# Cred erstellen
$secPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $secPassword)

#Hier wird die Zeit berechnet und in Variablen übergeben. 
$end = Get-Date -UFormat "%Y-%m-%dT%T"
$hour = Get-Date -UFormat "%HH"
$_hour = $hour.trimend("H")
$int_hour = [int]$_hour
# Hier die Zeit aus dem Feld eintragen mailstoreZeit
$value = Ninja-Property-Get -Name mailstoreZeit 
$int_hour = (24 - $value + $int_hour) % 24 
$Start = Get-Date -UFormat "%Y-%m-%dT%T" -Hour $int_hour

#Hier wird der Body defniert und die Start und end Zeit übergben für die Abfrage.
$body = @{
fromIncluding = $Start
toExcluding = $end
timeZoneID = '$Local'
}

# Hier der der Header befüllt
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", 'application/json')
# Hier wird die API abfrage erstellt
$response = Invoke-RestMethod -Uri "$api_url" -SkipCertificateCheck  -Authentication Basic -Credential $credential -Method Post -Body $body -Headers $headers

# Hier wird das erste fehlerhafte Zeichen übersprungen 
$res = $response.substring(1)

# Hier wird der String in eine Json umgewandelt
$profiles = $res | Convertfrom-json

#Hier wird der Failcounter angelegt
$failcount = 0

# Dies ist die Variable in der die Fehlerhaften jobs gespeichert werden. 
$fails = @()

# Dies ist die foreach schleife in der all Profile durchgegangen werden und wenn es fehler gibt, dann wird der Failcounter hochgezählt und dern Profil name in der Fails variable gespeichert.  
 foreach ($Profile in $profiles.result){
  if ($Profile.result -eq "failed" -or $Profile.result -eq "completedWithErrors" -or $Profile.result -eq "completedWithWarnings"){
        $failcount++    
        $fails += $Profile.profileName
    }    
}

# Hier wird die Variable befüllt dis den Schwellwert angibt ab wann das SKript einen Fehler ausbigt.   MailstroreFehler
$maxfails = Ninja-Property-Get -Name MailstroreFehler

# Hier sind die Variablen hinterlegt die inder "if" anweisung befüllt werden damit sie außerhalt davon genutzte werden können
$fehler = ""
$keinfehler = ""

# Hier wird geprüft ob der Schwellwert überschritten wurde. Wenn ja dann werden die Varibalen für Failcounter und Fails ausgegeben.
if ($failcount -ge $maxfails){
    $fehler = "Es sind Fehler aufgetreten:" + $failcount + " " + $fails
 } else {
     $keinfehler = "Es sind keine Fehler aufgetreten."
 }

# Ausgabe in der Shell für die gegenprüfung
Write-Host $fehler
Write-Host $keinfehler


# hier wird die ausgabe an Ninja übergben
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set MailstoreAusgabe $fehler $keinfehler