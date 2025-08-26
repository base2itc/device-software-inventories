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

# Importieren Sie das erforderliche Modul
# Stellen Sie sicher, dass das Modul auf Ihrem System installiert ist
Import-Module -Name SqlServer

# Definieren Sie die Verbindungsparameter
$server = "SQL01"
$database = "GONTEN"
$maxLogSize = 1000 # in MB
$maxDbSize = 1000 # in MB
$serviceAccountUsername = "svc_gn"
$serviceAccountPassword = ConvertTo-SecureString "2z1EnQ9m5HqpcUEtFpvH" -AsPlainText -Force

# Stellen Sie eine Verbindung zu SQL Server her
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=$server;Database=$database;User Id=$serviceAccountUsername;Password=$serviceAccountPassword;"
$sqlConnection.Open()

# Erstellen Sie eine neue SQL-Befehl
$sqlCommand = $sqlConnection.CreateCommand()

# Überprüfen Sie die Größe des Transaktionsprotokolls
$sqlCommand.CommandText = "DBCC SQLPERF(LOGSPACE)"
$logSpaceTable = New-Object System.Data.DataTable
$logSpaceTable.Load($sqlCommand.ExecuteReader())
$logSize = $logSpaceTable | Where-Object {$_.Database_Name -eq $database} | Select-Object -ExpandProperty Log_Size
if ($logSize -gt $maxLogSize) {
    Write-Output "Warnung: Die Größe des Transaktionsprotokolls ($logSize MB) hat die maximale Größe ($maxLogSize MB) überschritten."
}

# Überprüfen Sie die Größe der Datenbank
$sqlCommand.CommandText = "SELECT SUM(size * 8.0 / 1024) FROM sys.master_files WHERE database_id = DB_ID('$database') AND type = 0"
$dbSize = $sqlCommand.ExecuteScalar()
if ($dbSize -gt $maxDbSize) {
    Write-Output "Warnung: Die Größe der Datenbank ($dbSize MB) hat die maximale Größe ($maxDbSize MB) überschritten."
}

# Schließen Sie die Verbindung zu SQL Server
$sqlConnection.Close()
