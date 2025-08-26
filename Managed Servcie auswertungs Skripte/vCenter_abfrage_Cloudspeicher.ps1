# Verbindung zum vCenter-Server herstellen
$vcenterServer = "vcenter01.intern.ten-it.de"

$Username = "administrator@vsphere.local"
$Pass = ConvertTo-SecureString 'XCRPwTFM6$HZnFNf4BO"' -asplaintext -force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Pass)
Connect-VIServer -Server $vCenterServerIP -Credential $Cred

Connect-VIServer -Server $vcenterServer -Credential $cred

# Liste der Datastores, die abgefragt werden sollen
$datastoreNames = @("FWZ-Datastore01", "PPUG-Datastore01", "GreicheIP-Datastore01")


# Variablen zum Speichern der Ausgaben. Wenn die Drei nicht mehr reichen kann dies bellibig weiter geführt werden. Es muss dann nur der Rest des Skriptes um den weiteren Kunden erwietert werden.
$datastoreOutput1 = $null
$datastoreOutput2 = $null
$datastoreOutput3 = $null

foreach ($datastoreName in $datastoreNames) {
    Write-Host "Abfrage von Datastore: $datastoreName"
    # Datastore abrufen
    $datastore = Get-Datastore -Name $datastoreName

    if ($datastore) {
        # Datastore-Informationen speichern
        $output = $datastore | Select-Object Name, CapacityGB | Format-Table -AutoSize | Out-String
        Write-Host "Erfolgreich abgerufen: $output"
        
        # Ausgabe in die entsprechende Variable speichern. Dies belidig weiter geführt werden.
        switch ($datastoreName) {
            "FWZ-Datastore01" { $datastoreOutput1 = $output }
            "PPUG-Datastore01" { $datastoreOutput2 = $output }
            "GreicheIP-Datastore01" { $datastoreOutput3 = $output }
        }
    } else {
        Write-Host "Datastore $datastoreName nicht gefunden."
        switch ($datastoreName) {
            "FWZ-Datastore01" { $datastoreOutput1 = "Datastore $datastoreName nicht gefunden." }
            "PPUG-Datastore01" { $datastoreOutput2 = "Datastore $datastoreName nicht gefunden." }
            "GreicheIP-Datastore01" { $datastoreOutput3 = "Datastore $datastoreName nicht gefunden." }
        }
    }
}

# Ausgabe anzeigen
Write-Host "Informationen für Datastore: Datastore1"
Write-Host $datastoreOutput1
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set FWZCloudSpeicher $datastoreOutput1
Write-Host "----------------------------------------"

Write-Host "Informationen für Datastore: Datastore2"
Write-Host $datastoreOutput2
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set ppugCloudSpeicher $datastoreOutput2
Write-Host "----------------------------------------"

Write-Host "Informationen für Datastore: Datastore3"
Write-Host $datastoreOutput3
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set greicheCloudSpeicher $datastoreOutput3
Write-Host "----------------------------------------"



# Verbindung zum vCenter-Server trennen
Disconnect-VIServer -Server $vcenterServer -Confirm:$false