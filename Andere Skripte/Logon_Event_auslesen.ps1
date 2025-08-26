# Locked Out User definieren
$User = 'Administrator'

# Domain Controller mit PDC Emulator Rolle ermitteln
$PDC = (Get-AdDomain).PDCEmulator

# Parameterliste für die Event-Abfrage erstellen
$GweParams = @{
     'Computername' = $PDC
     'LogName' = 'Security'
     'FilterXPath' = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$User']]"
}

# Security Event Log abfragen
$Events = Get-WinEvent @GweParams

$Events