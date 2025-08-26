<#
.SYNOPSIS
    Installiert eine vordefinierte oder benutzerdefinierte Liste von Anwendungen über Winget.

.BESCHREIBUNG
    Dieses Skript nutzt Winget, um Standardprogramme auf einem Windows-Client zu installieren.
    Es prüft zunächst, ob Winget verfügbar ist, installiert es bei Bedarf automatisch und führt dann
    die Installation der gewünschten Programme durch. Winget-Quellen werden bei Fehlern repariert.

.PARAMETER Packages
    Eine Liste von Programmen (per Winget-ID), die installiert werden sollen.
    Standardmäßig werden Firefox, TeamViewer Host, Acrobat Reader und Microsoft Office installiert.

.PARAMETER SkipReboot
    Wenn angegeben, wird das System nach der Installation **nicht** automatisch neu gestartet.

.ANWENDUNG
    # Standardanwendungen installieren:
    Install-StandardAppsWithWinget

    # Eigene Programmliste:
    Install-StandardAppsWithWinget -Packages @("Google.Chrome", "Notepad++.Notepad++")

    # Ohne automatischen Neustart:
    Install-StandardAppsWithWinget -SkipReboot

.HINWEIS
    - Das Skript sollte mit Administratorrechten ausgeführt werden.
    - Bei der ersten Nutzung wird automatisch das PSWindowsUpdate-Modul installiert.
#>

function Install-StandardAppsWithWinget {
    [CmdletBinding()]
    param (
        [string[]]$Packages = @(
            "Mozilla.Firefox",
            "TeamViewer.TeamViewer.Host",
            "Adobe.Acrobat.Reader.64-bit",
            "Microsoft.Office"
        ),
        [switch]$SkipReboot
    )

    function Install-Winget {
        Write-Output "📦 Winget nicht gefunden. Versuche Installation..."

        $installerUrl = "https://aka.ms/getwinget"
        $tempPath = "$env:TEMP\AppInstaller.appxbundle"

        try {
            Invoke-WebRequest -Uri $installerUrl -OutFile $tempPath
            Add-AppxPackage -Path $tempPath
            Write-Output "✅ Winget wurde erfolgreich installiert."
        } catch {
            Write-Error "❌ Fehler bei der Installation von Winget: $_"
            exit 1
        }
    }

    function Repair-WingetSource {
        Write-Output "🔧 Repariere Winget-Quellen (source reset)..."
        try {
            winget source reset --force
            Start-Sleep -Seconds 2
            winget source list
            Write-Output "✅ Winget-Quellen zurückgesetzt."
        } catch {
            Write-Warning "⚠️ Fehler beim Zurücksetzen der Quellen: $_"
        }
    }

    # Prüfen, ob Winget installiert ist
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Install-Winget
        Start-Sleep -Seconds 5

        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Error "❌ Winget konnte nicht installiert werden. Abbruch."
            exit 1
        }
    } else {
        Write-Output "✅ Winget ist bereits installiert."
    }

    # Pakete installieren
    foreach ($package in $Packages) {
        Write-Output "📥 Installiere: $package"

        try {
            winget install --id "$package" --silent --accept-package-agreements --accept-source-agreements -e
            Write-Output "✔️ $package erfolgreich installiert."
        } catch {
            if ($_.ToString() -like "*0x8a15000f*") {
                Write-Warning "⚠️ Winget-Quelle fehlt oder ist defekt. Repariere..."
                Repair-WingetSource
                Write-Output "🔁 Wiederhole Installation von ${package}..."
                try {
                    winget install --id "$package" --silent --accept-package-agreements --accept-source-agreements -e
                    Write-Output "✔️ ${package} erfolgreich installiert nach Reparatur."
                } catch {
                    Write-Warning "❌ Fehler beim zweiten Versuch, ${package} zu installieren: $_"
                }
            } else {
                Write-Warning "⚠️ Fehler beim Installieren von ${package}: $_"
            }
        }
    }

    Write-Output "✅ Alle Installationen abgeschlossen."

    if (-not $SkipReboot) {
        Write-Output "♻️ System wird in 5 Sekunden automatisch neu gestartet..."
        Start-Sleep -Seconds 5
        Restart-Computer -Force
    } else {
        Write-Output "⏭️ Neustart übersprungen (per Parameter)."
    }
}
