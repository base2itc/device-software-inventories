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
#description>Dieser Sensor gibt die Anzahl der SentinelOne-Bedrohungen aus, die aktuell vorliegen. Als Parameter muss die siteID des Kunden eingetragen werden.</description>

# Parameter Variablen befüllen
#Abfragen der Felder in der die Site ID steht. 

$SiteIDCostumFiled = Ninja-Property-Get -Name SiteIDSentinel

#Abfragen der Felder in der, der API Token steht.

$APITokenCostumFiled = Ninja-Property-Get -Name APITokenSentinel

$siteID = $SiteIDCostumFiled
$apiT = $APITokenCostumFiled


[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

$apiT = "apiToken=$apiT"
$siteID = "siteIds=$siteID"
$url = "https://euce1-ten-it.sentinelone.net/web/api/v2.1/private/threats/summary?$siteID&$apiT"
$s1 = Invoke-RestMethod -Method 'Get' -Uri $url | Select-Object -ExpandProperty Data | Select notResolved
$exitCode = 0
$total = $s1.notResolved

if ($total -ne 0) {

    $alarm = "Es liegen $total Bedrohungen vor."
    $exitCode = -1
    
} else {
 
    $keinAlarm = "Es liegen keine Bedrohungen vor."
    $exitCode = 0

}

#exit 
$keinAlarm, $alarm, $exitCode

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set SentinelOneAlarm $keinAlarm, $alarm, $exitCode