# Ausführliche Beschreibung und Anwendung siehe Kommentare am Anfang des Skripts

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

Install-StandardAppsWithWinget