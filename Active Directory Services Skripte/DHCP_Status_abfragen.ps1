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

# Importieren des DHCP-Server-Moduls
Import-Module DhcpServer

# Abrufen aller Bereiche vom DHCP-Server
$scopes = Get-DhcpServerv4Scope

# Erstellen eines leeren HashTables zur Speicherung der Ausgaben
$outputs = @{}

# Variable zur Überprüfung, ob Fehler aufgetreten sind
$errorOccurred = $false

# Durchlaufen aller Bereiche
foreach ($scope in $scopes) {
    try {
        # Abrufen der Statistiken für den aktuellen Bereich
        $stats = Get-DhcpServerv4ScopeStatistics -ScopeId $scope.ScopeId

        # Berechnen der Gesamtzahl der Adressen im Bereich
        $startIP = [System.Net.IPAddress]::Parse($scope.StartRange).GetAddressBytes()
        [Array]::Reverse($startIP)
        $startIP = [System.BitConverter]::ToUInt32($startIP, 0)

        $endIP = [System.Net.IPAddress]::Parse($scope.EndRange).GetAddressBytes()
        [Array]::Reverse($endIP)
        $endIP = [System.BitConverter]::ToUInt32($endIP, 0)

        $totalAddresses = $endIP - $startIP + 1

       # Berechnen des Prozentsatzes der freien Adressen
        $freePercentage = [math]::Round(($stats.AddressesFree / $totalAddresses) * 100, 2)

        # Speichern der Ausgabe in einer Variable
        $outputs[$scope.Name] = @{
            'Insgesamt Adressen' = $totalAddresses
            'Verwendete Adressen' = $stats.AddressesInUse
            'Freie Adressen' = "$($stats.AddressesFree) (${freePercentage}% frei)"
            'Fehler' = "Keine Fehler"
        }
    }
    catch {
        # Speichern des Fehlers in einer Variable
        $outputs[$scope.Name] = @{
            'Fehler' = $_.Exception.Message
        }

        # Setzen der Fehlerüberprüfungsvariable auf wahr
        $errorOccurred = $true
    }
}

# Ausgabe der gespeicherten Informationen
foreach ($name in $outputs.Keys) {
    if ($outputs[$name]['Fehler'] -eq "Keine Fehler") {
        Write-Output "Bereich: $name"
        Write-Output "  Insgesamt Adressen: $($outputs[$name]['Insgesamt Adressen'])"
        Write-Output "  Verwendete Adressen: $($outputs[$name]['Verwendete Adressen'])"
        Write-Output "  Freie Adressen: $($outputs[$name]['Freie Adressen'])"
        Write-Output "  Status: $($outputs[$name]['Fehler'])"
    }
    else {
        Write-Output "Bereich: $name"
        Write-Output "  Fehler: $($outputs[$name]['Fehler'])"
    }
}

# Überprüfen, ob Fehler aufgetreten sind und Ausgabe einer entsprechenden Meldung
if ($errorOccurred) {
   $Fehler = Write-Output "Es gab Fehler bei einigen Bereichen."
} else {
   $Erfolg = Write-Output "Es gab keine Fehler bei allen Bereichen."
}

Write-Host -ForegroundColor Green $Fehler
Write-Host -ForegroundColor Green $Erfolg

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set DHCPStatus "$Erfolg $Fehler"