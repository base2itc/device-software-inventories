[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

 # Mailstore API URL, Benutzername und Passwort
 $api_url = "https://MGMT01.intern.averdung.de:8463/api/invoke/GetProfiles/"
 $username = "admin"
 $password = 'EGUWFT4rFmPWybXcCrFa'

 # Cred erstellen
 $secPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
 $credential = New-Object System.Management.Automation.PSCredential($username, $secPassword)

#  API Headers
#  $API_AuthHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#  $API_AuthHeaders.Add("fromIncluding",'2024-01-01T00:00:00')
#  $API_AuthHeaders.Add("toExcluding", '2024-01-04T00:00:00')
#  $API_AuthHeaders.Add("timeZoneId", '$Local')
#  $API_AuthHeaders.Add("Content-Type", 'application/x-www-form-urlencoded')

$headers = @{
   raw = "true"
}


 $response = Invoke-RestMethod -Uri "$api_url" -SkipCertificateCheck  -Authentication Basic -Credential $credential -Method Post -Body $headers

  #try {
 #    $response = Invoke-RestMethod -Uri "$api_url" -Method POST -Headers $API_AuthHeaders
 #} catch {
 #    Write-Output $_.Exception.Message
 #}

 # Überprüfender Antwort
 if ($response.StatusCode -eq 200) {
     $jobs = $response.Content | ConvertFrom-Json
     foreach ($job in $jobs) {
        # Job Prüfung
         if ($job.active -and $job.errors) {
             Write-Output "Job $($job.id) hat Fehler: $($job.errors)"
         }
     }
 } else {
     Write-Output "Fehler bei der Anfrage an die MailStore API:" $response

 }