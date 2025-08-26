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

#Wechselst in den Pfad in dem Skript liegt. 
cd "C:\Programme\Microsoft Office\Office16"

# Liest aus ob der Server eine Lizensierte Office version hat. 
# Wert für den unlizensierten Status = ---UNLICENSED---

# Führe das ospp.vbs-Skript mit dem Parameter /dstatus aus und filtere die Ausgabe nach dem Wort "STATUS"
$license_status = cscript ospp.vbs /dstatus | Select-String "STATUS"


# Überprüfe, ob der Wert ---LICENSED--- enthalten ist
if ($license_status -match "---LICENSED---") {

   $Lizensiert = Write-Output "Office 2019 ist lizenziert."

} else {
   
   $Lizensiert = Write-Output "Office 2019 ist nicht lizenziert."
}

Write-Host -ForegroundColor Green $Lizensiert

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe  set OfficeLizenz $Lizensiert
