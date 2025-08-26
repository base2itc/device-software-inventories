$ipaddress = 'IPAdresse'
$port = 'PORT'
$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port)
if ($connection.Connected) {
     Write-Host "Success" 
} else { 
     Write-Host "Failed" 
}