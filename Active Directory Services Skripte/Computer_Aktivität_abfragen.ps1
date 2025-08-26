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

# Importiere das Active Directory Modul
Import-Module ActiveDirectory

# Definiere die Anzahl der Tage
$Tage = 360

# Ermittle das Datum vor der angegebenen Anzahl von Tagen
$Datum = (Get-Date).AddDays(-$Tage)


# Diese werden durch ein Buntzerdefiniertes Feld übergeben. 
$IgnoreComputer = Ninja-Property-Get -Name IgnoreComputer


# Hier wird  auf null geprüft damit das Skript nicht durch eine null übergabe unterbrochen wird.
if($null -eq $IgnoreComputer){
  $IgnoreComputer = ""
} 


# Variable für die Organisationseinheit in der die User liegen. Diese werden durch ein Buntzerdefiniertes Feld übergeben. 
$OrgaUnit = Ninja-Property-Get -Name OUComputer

# Suche nach Computerobjekten in der angegebenen OU, die seit dem ermittelten Datum nicht mehr gesehen wurden und aktiv sind 
if($null -eq $OrgaUnit){
  $Computer = Get-ADComputer -Filter {LastLogonTimeStamp -lt $Datum -and Enabled -eq $true} -Property LastLogonTimeStamp
} else {

  $Computer = Get-ADComputer -Filter {LastLogonTimeStamp -lt $Datum -and Enabled -eq $true} -SearchBase $OrgaUnit -Property LastLogonTimeStamp
} 

# Definiere eine Variable für die Ausgabe
$Ausgabe = ""

# Überprüfe, ob Computer gefunden wurden
if ($Computer) {
    # Gebe die gefundenen Computer aus
    foreach ($c in $Computer) {
        if ($c.Name -notin $IgnoreComputer) {
            $Name = $c.Name
            $LastLogon = [DateTime]::FromFileTime($c.LastLogonTimeStamp)
            $Ausgabe += "Computer: $Name, Last Logon: $LastLogon`n"
        }
    }
} 

# Wenn keine Computer gefunden wurden, gebe eine entsprechende Nachricht aus
if ($Ausgabe -eq "") {
    $Ausgabe = "Alles ist in Ordnung, es wurden keine Computer gefunden, die länger als $Tage Tage offline sind."
}

# Gebe die Ausgabe aus
Write-Output $Ausgabe

#Werte in das Benutzerdefinierte Feld schreiben.
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set InaktiveComputer $Ausgabe