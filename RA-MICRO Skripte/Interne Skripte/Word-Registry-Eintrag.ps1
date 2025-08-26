# PowerShell-Skript zum Hinzufügen eines neuen Registrierungswerts

# Pfad zum Registry-Schlüssel
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Word\Options"

# Name des neuen Registry-Werts
$valueName = "ExportPictureWithMetafile"

# Typ des Werts (Zeichenfolge = REG_SZ)
$valueType = "String"

# Wert, der gesetzt werden soll
$valueData = "0"

# Erstellen oder Setzen des Registry-Werts
New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType $valueType -Force

Write-Host "Registrierungseintrag '$valueName' mit Wert '$valueData' wurde erfolgreich erstellt oder aktualisiert."
