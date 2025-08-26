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

# Importieren des erforderlichen Moduls
Import-Module ActiveDirectory

# Startzeit für die Überprüfung festlegen
$startTime = (Get-Date).AddMinutes(-30)

# Die Anzahl der zu prüfenden Anmeldeversuche festlegen
$maxFailedLoginAttempts = 500

# Variablen für die Ausgaben erstellen
$alarmMessage = ""
$userMessage = ""

# Abrufen der fehlerhaften Anmeldeereignisse
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$startTime} -ErrorAction Stop
} catch {
    $alarmMessage = "Alles in Ordnung, es wurden keine fehlerhaften Anmeldeversuche gefunden."
    Write-Output $alarmMessage
    C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set HackAlarm "$alarmMessage"
    return
    }

# Zählen der fehlerhaften Anmeldeversuche
$failedLoginAttempts = $events.Count

# Überprüfen, ob die Anzahl der fehlerhaften Anmeldeversuche größer als die festgelegte Maximalzahl ist
if ($failedLoginAttempts -gt $maxFailedLoginAttempts) {
    $alarmMessage = "Hack Alarm! Es gab mehr als $maxFailedLoginAttempts fehlerhafte Anmeldeversuche in den letzten 30 Minuten. Die genaue Anzahl beträgt: $failedLoginAttempts"
    
    # Ausgabe der Benutzernamen der fehlerhaften Anmeldeversuche
    $events | ForEach-Object {
        $eventXml = [xml]$_.ToXml()
        $username = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq 'TargetUserName'} | Select-Object -ExpandProperty '#text'
        $userMessage += "Fehlerhafter Anmeldeversuch von Benutzer: $username`n"
    }
} else {
    $alarmMessage = "Alles in Ordnung, es gab weniger als $maxFailedLoginAttempts fehlerhafte Anmeldeversuche in den letzten 30 Minuten. Die genaue Anzahl beträgt: $failedLoginAttempts"
}



C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set HackAlarm "$alarmMessage"

Successful rescans: QNAP01, QNAP01 - Externe Monats-HDD, QNAP01 - Externe Wochen-HDD Failed rescans:
Successful rescans: QNAP01, QNAP01 - Externe Monats-HDD, QNAP01 - Externe Wochen-HDD

