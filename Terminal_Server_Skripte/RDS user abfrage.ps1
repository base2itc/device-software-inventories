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


function Get-VMinformation(
        [parameter(mandatory)] [string] $DomainControllerName,
        [parameter(mandatory)] [string] $Domainname,
        [parameter(mandatory)] [string] $Gruppenname

    ) 
 #   {

# Prüfen ob das PowerShell VMware.PowerCLI Module Installiert ist.

#Write-Host "Prüfen ob das Modul Active Directory Modul installiert ist..." -ForegroundColor DarkYellow

#if (!(Get-Module -ListAvailable -Name "VMware.PowerCLI")) {

 #   Write-Host "VMware.powerCLI ist nicht Insttaliert. Installation gestartet..." -ForegroundColor DarkYellow

  #  Install-Module VMware.PowerCLI -Scope CurrentUser -Force

#}

# Setze die Variablen
$Group = "Gruppenname" # Der Name der Gruppe, die gezählt werden soll
$Domain = "Domainname" # Der Name der Active Directory-Domäne, in der sich die Gruppe befindet
$DC = "DomainControllerName" # Der Name des Domain Controllers, der für die Abfrage verwendet wird

# Verbinde mit dem Domain Controller
# Wenn erforderlich, gebe Anmeldeinformationen für eine privilegierte Verbindung ein
$Cred = Get-Credential 
$Session = New-PSSession -ComputerName $DC -Credential $Cred
Enter-PSSession $Session

# Zähle die Mitglieder der Gruppe
$GroupMembers = Get-ADGroupMember -Identity $Group -Server $DC -Recursive | Measure-Object
$MemberCount = $GroupMembers.Count

# Gib das Ergebnis aus
Write-Host "Die Gruppe '$Group' auf '$Domain' hat $MemberCount Mitglieder."

# Trenne die Sitzung
Exit-PSSession
Remove-PSSession $Session

}


