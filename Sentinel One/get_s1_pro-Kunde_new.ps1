<#

<description>Dieser Sensor gibt die Anzahl der SentinelOne-Bedrohungen aus, die aktuell vorliegen. Als Parameter muss die siteID des Kunden eingetragen werden.</description>

<version>1</version>

#>

Param(
    [Parameter(Mandatory = $true)] 
    $siteID,
	[Parameter(Mandatory = $true)] 
    $apiT
)

[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

$apiT = "apiToken=$apiT"
$siteID = "siteIds=$siteID"
$url = "https://euce1-ten-it.sentinelone.net/web/api/v2.1/private/threats/summary?$siteID&$apiT"
$s1 = Invoke-RestMethod -Method 'Get' -Uri $url | Select-Object -ExpandProperty Data | Select notResolved
$exitCode = 0
$total = $s1.notResolved

if ($total -ne 0) {

    "Es liegen $total Bedrohungen vor."
    $exitCode = -1
    
} else {
 
    "Es liegen keine Bedrohungen vor."
    $exitCode = 0

}

exit $exitCode
