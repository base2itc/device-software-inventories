<#
.SYNOPSIS
    Führt ein automatisiertes Client-Setup durch: 
    - Energiesparoptionen anpassen
    - Windows-Updates installieren
    - Rechnernamen ändern
    - Lokalen Admin-Benutzer mit zufälligem Passwort erstellen

.BESCHREIBUNG
    Dieses PowerShell-Skript dient dazu, einen neuen Client-PC schnell und automatisiert einzurichten.
    Es erkennt, ob ein Desktop oder Notebook verwendet wird, passt die Energieoptionen entsprechend an,
    installiert aktuelle Windows-Updates, setzt den neuen Computernamen, erstellt einen lokalen Admin-Account
    mit einem zufälligen Passwort und speichert die Zugangsdaten in einer Textdatei.

.ANWENDUNG
    1. Öffne PowerShell als Administrator.
    2. Navigiere in das Verzeichnis, in dem sich dieses Skript befindet:
       cd C:\Pfad\zum\Skript
    3. Lade das Skript in die aktuelle Session:
       . .\ClientSetup.ps1
    4. Starte die Initialisierung mit optionalem Namen:
       Initialize-ClientSetup -ComputerName "MeinNeuerClient"

    (Falls kein Parameter übergeben wird, wird "NeuerComputerName" als Standard verwendet.)

.AUSGABEN
    - Admin-Zugangsdaten unter: C:\AdminCredentials.txt

.HINWEIS
    - Ein Neustart nach der Umbenennung kann notwendig sein.
    - Das Update-Modul 'PSWindowsUpdate' wird automatisch installiert.
#>
<#
.SYNOPSIS
    Führt grundlegende Client-Konfiguration durch (z. B. Updates, Energiesparmodus, Admin-User, PC-Name).

.ANWENDUNG
    1. Skript mit Admin-Rechten ausführen.
    2. Dann den Befehl aufrufen: Initialize-ClientSetup

.PARAMETER ComputerName
    Neuer Name, der für den Computer gesetzt werden soll.
#>
function Initialize-ClientSetup {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    try {
        Write-Host "🔧 Starte Client-Initialisierung..." -ForegroundColor Cyan

        # Benutzer nach dem Computernamen fragen
        $ComputerName = Read-Host "Bitte den neuen Computernamen eingeben"

        $pcType = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType
        Write-Host "⚡ Passe Energiesparplan an (PC-Typ: $pcType)..."
        if ($pcType -eq 1) {
            powercfg -change -standby-timeout-ac 0
        } elseif ($pcType -eq 2) {
            powercfg -change -standby-timeout-ac 0
            powercfg -change -standby-timeout-dc 30
        }

        Write-Host "🖥️ Setze Rechnername auf '$ComputerName'..."
        Rename-Computer -NewName $ComputerName

        Write-Host "👤 Erstelle Admin-Benutzer..."
        $adminUsername = "AdminUser"
        $adminPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | ForEach-Object { [char]$_ })
        net user $adminUsername $adminPassword /add

        if (-not (Get-LocalGroup -Name "Administratoren" -ErrorAction SilentlyContinue)) {
            net localgroup Administratoren /add
        }
        net localgroup Administratoren $adminUsername /add

        $credPath = "C:\AdminCredentials.txt"
        "Username: $adminUsername`nPassword: $adminPassword" | Out-File -FilePath $credPath
        Write-Host "🔐 Admin-Zugang gespeichert unter $credPath"

        Write-Host "✅ Client-Setup erfolgreich abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Fehler bei der Initialisierung: $($_.Exception.Message)"
    }
}
