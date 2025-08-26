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

# Erstellen Sie zwei Variablen für erfolgreiche und fehlgeschlagene Jobs
$successfulJobs = @()
$failedJobs = @()

# Erstellen Sie zwei Variablen für den allgemeinen Erfolg oder Misserfolg der Durchführung
$executionSuccessful = $true
$executionFailed = $false

# Erstellen Sie Variablen für die Ausgabe
$successfulExecutionOutput = ""
$failedExecutionOutput = ""

# Erstellen Sie eine Liste von Jobnamen, die ausgeschlossen werden sollen
$excludeJobs = "Backup Copy CU_PPUG-Server ->HQ"

# Holen Sie sich alle Backup-Jobs, die nicht in der Ausschlussliste enthalten sind
$backupJobs = Get-VBRJob | Where-Object {$excludeJobs -notcontains $_.Name}

# Durchlaufen Sie jeden Job
foreach ($job in $backupJobs) {
    # Holen Sie sich die letzten Sitzungsinformationen für den Job
    $lastSession = $job.FindLastSession()
    
    # Überprüfen Sie, ob lastSession null ist
    if ($lastSession -ne $null) {
        $status = $lastSession.Info.Result

        # Wenn der Status fehlgeschlagen ist, fügen Sie den Job zur FailedJobs-Liste hinzu und setzen Sie executionFailed auf true
        if ($status -eq "Failed") {
            $failedVMs = $lastSession.GetTaskSessions() | Where-Object {$_.Status -eq "EWarning" -or $_.Status -eq "EFailed"} | ForEach-Object {$_.Info.ObjectName}
            $failedJobs += [PSCustomObject]@{
                JobName = $job.Name
                FailedVMs = $failedVMs
            }
            $executionFailed = $true
        }
        # Wenn der Status erfolgreich ist, fügen Sie den Job zur SuccessfulJobs-Liste hinzu und setzen Sie executionSuccessful auf true
        else {
            $successfulVMs = $lastSession.GetTaskSessions() | Where-Object {$_.Status -eq "ESuccess"} | ForEach-Object {$_.Info.ObjectName}
            $successfulJobs += [PSCustomObject]@{
                JobName = $job.Name
                SuccessfulVMs = $successfulVMs
            }
            $executionSuccessful = $true
        }
    }
}

# Speichern Sie die Ausgabe in den Variablen successfulExecutionOutput und failedExecutionOutput
if ($executionSuccessful) {
    $successfulExecutionOutput = "`nExecution was successful."
} else {
    $successfulExecutionOutput = "`nExecution was not successful."
}

if ($executionFailed) {
    $failedExecutionOutput = "There were some failures during the execution."
} else {
    $failedExecutionOutput = "There were no failures during the execution."
}

# Ausgabe der erfolgreichen und fehlgeschlagenen Jobs sowie des allgemeinen Erfolgs oder Misserfolgs der Durchführung
Write-Host "Successful Jobs:"
$successfulJobs | ForEach-Object {Write-Host "`t$($_.JobName):"; $_.SuccessfulVMs | ForEach-Object {Write-Host "`t`t$_"}}

Write-Host "`nFailed Jobs:"
$failedJobs | ForEach-Object {Write-Host "`t$($_.JobName):"; $_.FailedVMs | ForEach-Object {Write-Host "`t`t$_"}}

Write-Host -ForegroundColor Green "$successfulExecutionOutput"
Write-Host -ForegroundColor Green "$failedExecutionOutput"

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set VeeamBackupJob "$successfulExecutionOutput and $failedExecutionOutput"