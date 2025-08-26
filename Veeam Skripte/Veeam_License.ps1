# Importieren Sie das Veeam-Modul
Import-Module Veeam.Backup.PowerShell

# Verbinden Sie sich mit dem Veeam Backup Server
Connect-VBRServer -Server 10.82.10.21

# Abrufen der Lizenzinformationen
$license = Get-VBRInstalledLicense

$license.ExpirationDate
$license.Edition

# Ausgabe der Lizenzinformationen
$license
