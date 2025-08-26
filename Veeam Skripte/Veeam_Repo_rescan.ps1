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

# Importieren Sie das Veeam-Modul
Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

# Erstellen Sie ein Array, um die Ergebnisse der Rescans zu speichern
$rescanResults = @()

# Holen Sie alle Backup-Repositories
$repositories = Get-VBRBackupRepository

# Durchlaufen Sie jedes Repository und führen Sie einen Rescan durch
foreach ($repo in $repositories) {
    $result = New-Object PSObject -Property @{
        Repository = $repo.Name
        RescanSuccessful = $false
    }
    try {
        # Führen Sie den Rescan durch und fangen Sie mögliche Fehler ab
        Sync-VBRBackupRepository -Repository $repo -ErrorAction Stop
        $result.RescanSuccessful = $true
    } catch {
        # Nichts zu tun, da RescanSuccessful standardmäßig auf false gesetzt ist
    }
    $rescanResults += $result
}

# Erstellen Sie Strings für die erfolgreichen und fehlgeschlagenen Rescans
$successfulRescans = ($rescanResults | Where-Object { $_.RescanSuccessful } | ForEach-Object { $_.Repository }) -join ', '
$failedRescans = ($rescanResults | Where-Object { -not $_.RescanSuccessful } | ForEach-Object { $_.Repository }) -join ', '

# Speichern Sie die Ergebnisse in Variablen
$successfulRescansOutput = "Successful rescans: $successfulRescans"
$failedRescansOutput = "Failed rescans: $failedRescans"

# Geben Sie die Variablen aus (optional)
Write-Host $successfulRescansOutput
Write-Host $failedRescansOutput

# Hier wird das Buntzerdefinierte Feld ausgefüllt.
C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set VeeamRescan "$successfulRescansOutput $failedRescansOutput"
