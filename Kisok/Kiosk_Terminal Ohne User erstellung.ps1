# ============================
# KONFIGURATION
# ============================
$kioskUser = "KioskRea3"
$kioskPassword = "S!chweIn26060!"
$appPath = "C:\Program Files (x86)\aktivKONZEPTE\aktivSYSTEM\aktivSYSTEM-User\WinUser.exe"

# ============================
# 2. Autologin aktivieren
# ============================
Write-Host "Autologin wird konfiguriert..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername" -Value $kioskUser
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $kioskPassword

# ============================
# 3. Shell ersetzen NUR für den Kiosk-User
# ============================

Write-Host "Shell-Replacement wird eingerichtet..."

# Kiosk-SID ermitteln
$kioskSid = (Get-LocalUser -Name $kioskUser).Sid.Value
$registryPath = "Registry::HKEY_USERS\$kioskSid\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Sicherstellen, dass der User einmal angemeldet wurde (damit der SID-Zweig vorhanden ist)
if (-not (Test-Path $registryPath)) {
    Write-Warning "Der Benutzer '$kioskUser' muss sich mindestens einmal anmelden, damit der Registry-Zweig existiert."
    Write-Warning "Starte das System einmal mit dem Kiosk-User, dann führe diesen Teil erneut aus."
} else {
    New-ItemProperty -Path $registryPath -Name "Shell" -Value $appPath -PropertyType String -Force
    Write-Host "Benutzerdefinierte Shell für '$kioskUser' gesetzt: $appPath"
}

# ============================
# ABSCHLUSS
# ============================
Write-Host "`n Einrichtung abgeschlossen! Beim nächsten Neustart wird '$kioskUser' automatisch angemeldet und startet direkt die gewünschte App." -ForegroundColor Green
