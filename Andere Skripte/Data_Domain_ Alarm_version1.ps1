# This script checks for alerts on a Data Domain system using the DDOS command line interface

# Assign the arguments to variables
$hostname = '10.10.25.30'
$username = 'sysadmin'
$password = 'A9X3COiR&1MSKO!PJjL!'

# Load the Posh-SSH module to use SSH commands
Import-Module Posh-SSH

# Create a new SSH session to the Data Domain system using the credentials with StrictHostKeyChecking disabled
$session = New-SSHSession -ComputerName $hostname -Credential (New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString $password -AsPlainText -Force))) -AcceptKey

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
$Anzeige = $output.Output
$Anzeige 

C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe  set DataDomainAlert $Anzeige