<#
.SYNOPSIS
    Aktiviert BitLocker auf dem Systemlaufwerk (C:) und speichert den Wiederherstellungsschlüssel lokal.

.BESCHREIBUNG
    Diese Funktion prüft, ob BitLocker bereits aktiv ist. Falls nicht, wird BitLocker auf Laufwerk C: aktiviert.
    Wenn kein TPM vorhanden ist, wird die notwendige Gruppenrichtlinie gesetzt.
    Der Wiederherstellungsschlüssel wird nach der Aktivierung unter C:\BitLocker\RecoveryKey.txt gespeichert.

.ANWENDUNG
    1. Skript in einer administrativen PowerShell ausführen:
       .\Enable-BitLockerSmart.ps1
    2. Dann den Befehl eingeben:
       Enable-BitLockerSmart
#>
function Enable-BitLockerSmart {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"
    Write-Host "⏳ Starte BitLocker-Setup..." -ForegroundColor Cyan

    try {
        $system = Get-WmiObject -Class Win32_ComputerSystem
        if ($system.PCSystemType -ne 2) {
            Write-Host "💻 Kein Notebook erkannt – BitLocker wird trotzdem versucht (z. B. VM)..." -ForegroundColor Yellow
        }

        Write-Host "🔍 Prüfe BitLocker-Status..."
        $bitlockerStatus = Get-BitLockerVolume -MountPoint "C:"
        if ($bitlockerStatus.ProtectionStatus -ne 0) {
            Write-Host "🔐 BitLocker ist bereits aktiviert." -ForegroundColor Green
            return
        }

        Write-Host "🔍 Prüfe TPM..."
        $tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction SilentlyContinue
        $hasTPM = $tpm -and $tpm.IsEnabled_InitialValue -eq $true -and $tpm.IsActivated_InitialValue -eq $true

        if (-not $hasTPM) {
            Write-Warning "⚠️ Kein TPM erkannt – setze Gruppenrichtlinie für BitLocker ohne TPM..."

            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }

            Set-ItemProperty -Path $regPath -Name "EnableBDEWithNoTPM" -Value 1 -Type DWord
            Set-ItemProperty -Path $regPath -Name "UseAdvancedStartup" -Value 1 -Type DWord
            Set-ItemProperty -Path $regPath -Name "OSRecovery" -Value 2 -Type DWord

            Write-Host "🔁 Richtlinie gesetzt. Fahre mit Aktivierung fort..."
        } else {
            Write-Host "✅ TPM erkannt. Fahre mit Aktivierung fort..."
        }

        Write-Host "🔐 Aktiviere BitLocker auf Laufwerk C:..."
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -RecoveryPasswordProtector -Verbose

        Start-Sleep -Seconds 10
        $bitlockerVolume = Get-BitLockerVolume -MountPoint "C:"
        $recoveryKey = $bitlockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

        $recoveryFolder = "C:\BitLocker"
        if (-not (Test-Path $recoveryFolder)) {
            New-Item -Path $recoveryFolder -ItemType Directory | Out-Null
        }

        if ($recoveryKey) {
            $recoveryKey.RecoveryPassword | Out-File "$recoveryFolder\RecoveryKey.txt"
            Write-Host "🔑 Recovery Key gespeichert unter $recoveryFolder\RecoveryKey.txt" -ForegroundColor Green
        } else {
            Write-Warning "❗ Recovery Key konnte nicht gespeichert werden."
        }

        Write-Host "✅ BitLocker wurde erfolgreich aktiviert!" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Fehler bei der BitLocker-Aktivierung: $($_.Exception.Message)"
    }
}

Enable-BitLockerSmart
