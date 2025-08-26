# This script checks for alerts on a Data Domain system using the DDOS command line interface
# It requires SSH access to the Data Domain system and a valid username and password
# Usage: .\check_alerts.ps1 <hostname> <username> <password>

# Check if the arguments are valid
if ($args.Count -ne 3) {
  Write-Host "Invalid arguments. Usage: .\check_alerts.ps1 <ddve01.intern.ten-it.de> <sysadmin> <I=U?w8bW-0NHp7#cr9!9>"
  exit 1
}

# Assign the arguments to variables
$hostname = $args[0]
$username = $args[1]
$password = $args[2]

# Load the Posh-SSH module to use SSH commands
Import-Module Posh-SSH

# Create a new SSH session to the Data Domain system using the credentials
$session = New-SSHSession -ComputerName $hostname -Credential (New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString $password -AsPlainText -Force)))

# Check if the session was successful
if ($session) {
  # Execute the alerts show current command on the Data Domain system using SSH
  $output = Invoke-SSHCommand -SessionId $session.SessionId -Command "alerts show current"

  # Check if the output is empty, which means there are no alerts
  if ($output.Output -eq "") {
    Write-Host "There are no alerts on the Data Domain system."
  }
  else {
    # Print the output, which contains the alerts information
    Write-Host "The following alerts are present on the Data Domain system:"
    Write-Host $output.Output
  }

  # Remove the SSH session
  Remove-SSHSession -SessionId $session.SessionId
}
else {
  # Print an error message if the session failed
  Write-Host "An error occurred while creating the SSH session to the Data Domain system."
}
