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


function Get-RDSUser(
        [parameter(mandatory)] [string] $Domainname,
        [parameter(mandatory)] [string] $Gruppenname

    ){ 

# Setze die Variablen
$Group = "$Gruppenname" # Der Name der Gruppe, die gezählt werden soll
$Domain = "$Domainname" # Der Name der Active Directory-Domäne, in der sich die Gruppe befindet

# Zähle die Mitglieder der Gruppe             
$GroupMembers = Get-ADGroupMember -Identity $Group 
$MemberCount = $GroupMembers.Count

# Gib das Ergebnis aus
Write-Host "Die Gruppe '$Group' auf '$Domain' hat $MemberCount Mitglieder." -ForegroundColor Yellow


}


