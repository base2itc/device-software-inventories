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

# Importiere das ActiveDirectory Modul
Import-Module ActiveDirectory

# Erstelle eine leere Liste für die Ergebnisse
$Results = @()

# Liste der Benutzerkonten, die ignoriert werden sollen
$IgnoreUsers =

# Suche nach allen Benutzern im Active Directory
$Users = Get-ADUser -SearchBase "OU=Mitarbeiter,OU=User,OU=HH,OU=TEN,DC=intern,DC=ten-it,DC=de" -Filter * -Properties LastLogonDate | Where {$_.enabled -eq $true}
[datetime]$ToDay= Get-Date 

# Durchlaufe jeden Benutzer
foreach ($User in $Users) {
    # Überspringe Benutzer, die ignoriert werden sollen
    if ($User.SamAccountName -in $IgnoreUsers) {
        continue
    }

 # Überprüfe, ob das LastLogonDate-Attribut gesetzt ist
    if ($User.LastLogonDate -ne $null) {
        # Berechne die Anzahl der Tage seit dem letzten Login
        $endzeit = $user.LastLogonDate
        $DaysOffline = New-TimeSpan -Start $endzeit -End $ToDay
        $AnzahlTage = $DaysOffline.TotalDays

        if ($AnzahlTage -gt 365) {
            $Results += [PSCustomObject]@{
                Name = $User.Name
                "Offline seit" = [Math]::Floor($DaysOffline.TotalDays) 
            }
        }    
    }
}

# Überprüfe, ob Ergebnisse vorhanden sind
if ($Results.Count -gt 0) {
    # Zeige die Ergebnisliste auf der Konsole an
    $Results | Format-Table -AutoSize 

    C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set InaktiverUser $Results
} else {
    # Keine Benutzer erfüllen die Kriterien, gib eine Meldung aus
    $Message = "Alles ist in Ordnung, es gibt keine Benutzer, die die Kriterien erfüllen."
    Write-Output $Message

    C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set InaktiverUser $Message
}