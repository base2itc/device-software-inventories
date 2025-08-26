<#
.SYNOPSIS
    Dieses PowerShell-Modul bietet eine Funktion zum Konfigurieren eines neuen Domain Controllers. 
    Die Funktion führt mehrere Schritte durch, darunter das Umbenennen des Servers, das Konfigurieren von IP- und DNS-Einstellungen, 
    das Installieren von Active Directory-Domain-Services (AD DS) und das Hinzufügen des Servers als Domain Controller.

.DESCRIPTION
    Mit diesem Skript können Sie einen neuen Server als Domain Controller für eine bestehende Domäne konfigurieren.
    Es fragt nach verschiedenen Konfigurationsparametern und führt dann die notwendigen Schritte durch, um den Server zu 
    einem Domain Controller zu machen.

.PARAMETER NewServerName
    Der Name des neuen Servers.

.PARAMETER IPAddress
    Die statische IP-Adresse des Servers.

.PARAMETER SubnetMask
    Die Subnetzmaske des Servers.

.PARAMETER DefaultGateway
    Das Standardgateway des Servers.

.PARAMETER PrimaryDNSServer
    Die Adresse des primären DNS-Servers.

.PARAMETER SecondaryDNSServer
    Die Adresse des sekundären DNS-Servers.

.PARAMETER DomainName
    Der Name der Domäne, zu der der Server gehören wird.

.PARAMETER NetBIOSName
    Der NetBIOS-Name der Domäne.

.PARAMETER SafeModePassword
    Das DSRM-Kennwort (Directory Services Restore Mode) des neuen Domain Controllers.

.PARAMETER ForestMode
    Der Forest Functional Level der Domäne (z.B. Win2016).

.PARAMETER DomainMode
    Der Domain Functional Level der Domäne (z.B. Win2016).

.PARAMETER ExistingDC
    Der Name eines bestehenden Domain Controllers in der Domäne, dessen DNS-Auflösung überprüft wird.

.PARAMETER Credential
    Die Anmeldedaten des Benutzers, der die Installation und Konfiguration durchführen wird.

.EXAMPLE
    # Beispiel für die Verwendung des Skripts:
    # Das folgende Beispiel zeigt, wie die Funktion mit ausgefüllten Parametern aufgerufen wird.
    
    $Credential = Get-Credential  # Hier werden die Anmeldedaten des Administrators abgefragt.
    
    Set-ServerConfiguration -NewServerName "Server01" `
                            -IPAddress "192.168.1.100" `
                            -SubnetMask "255.255.255.0" `
                            -DefaultGateway "192.168.1.1" `
                            -PrimaryDNSServer "8.8.8.8" `
                            -SecondaryDNSServer "8.8.4.4" `
                            -DomainName "example.com" `
                            -NetBIOSName "EXAMPLE" `
                            -SafeModePassword (ConvertTo-SecureString "P@ssw0rd" -AsSecureString) `
                            -ForestMode "Win2016" `
                            -DomainMode "Win2016" `
                            -ExistingDC "DC01" `
                            -Credential $Credential

#>

function Set-ServerConfiguration {
    param (
        [string]$NewServerName,
        [string]$IPAddress,
        [string]$SubnetMask,
        [string]$DefaultGateway,
        [string]$PrimaryDNSServer,
        [string]$SecondaryDNSServer,
        [string]$DomainName,
        [string]$NetBIOSName,
        [SecureString]$SafeModePassword,
        [string]$ForestMode,
        [string]$DomainMode,
        [string]$ExistingDC,
        [PSCredential]$Credential
    )

    # Abfrage der notwendigen Variablen, falls sie nicht übergeben wurden
    if (-not $NewServerName) {
        $NewServerName = Read-Host "Geben Sie den neuen Servernamen ein"
    }
    if (-not $IPAddress) {
        $IPAddress = Read-Host "Geben Sie die neue IP-Adresse ein"
    }
    if (-not $SubnetMask) {
        $SubnetMask = Read-Host "Geben Sie die Subnetzmaske ein"
    }
    if (-not $DefaultGateway) {
        $DefaultGateway = Read-Host "Geben Sie das Standardgateway ein"
    }
    if (-not $PrimaryDNSServer) {
        $PrimaryDNSServer = Read-Host "Geben Sie die primäre DNS-Server-Adresse ein"
    }
    if (-not $SecondaryDNSServer) {
        $SecondaryDNSServer = Read-Host "Geben Sie die alternative DNS-Server-Adresse ein"
    }
    if (-not $DomainName) {
        $DomainName = Read-Host "Geben Sie den Domainnamen ein (z.B. example.com)"
    }
    if (-not $NetBIOSName) {
        $NetBIOSName = Read-Host "Geben Sie den NetBIOS-Namen der Domäne ein (z.B. EXAMPLE)"
    }
    if (-not $SafeModePassword) {
        $SafeModePassword = Read-Host "Geben Sie das DSRM-Kennwort ein" -AsSecureString
    }
    if (-not $ForestMode) {
        $ForestMode = Read-Host "Geben Sie den Forest Functional Level ein (z.B. Win2016)"
    }
    if (-not $DomainMode) {
        $DomainMode = Read-Host "Geben Sie den Domain Functional Level ein (z.B. Win2016)"
    }
    if (-not $ExistingDC) {
        $ExistingDC = Read-Host "Geben Sie den Namen eines bestehenden Domain Controllers ein"
    }

    # Wenn keine Anmeldedaten übergeben wurden, erstelle sie und speichere sie in einer Variablen
    if (-not $Credential) {
        $Credential = Get-Credential
    }

    # Umbenennen des Servers
    Write-Host "Der Server wird jetzt umbenannt und neu gestartet."
    Rename-Computer -NewName $NewServerName -Force -Restart

    # Warten auf Neustart (optimiert auf 60 Sekunden)
    Start-Sleep -Seconds 60

    # Anpassung der IP- und DNS-Einstellungen
    $InterfaceIndex = Get-NetAdapter -Name "Ethernet" | Select-Object -ExpandProperty ifIndex

    # Berechnung des PrefixLength basierend auf der Subnetzmaske
    $PrefixLength = [System.Net.IPAddress]::Parse($SubnetMask).GetAddressBytes().Count * 8 - ($SubnetMask.Split('.') | ForEach-Object { [convert]::ToByte($_) }) | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $PrimaryDNSServer, $SecondaryDNSServer

    # Überprüfung der DNS-Auflösung der bestehenden Domäne
    Write-Host "Überprüfe die DNS-Auflösung der bestehenden Domäne..."
    $NslookupResult = nslookup $ExistingDC

    # Überprüfung der DNS-Auflösung
    while ($NslookupResult -notmatch "Name:.*$ExistingDC") {
        Write-Host "DNS-Auflösung fehlgeschlagen: $ExistingDC"
        $ExistingDC = Read-Host "Bitte überprüfen Sie den Namen des bestehenden Domain Controllers und geben Sie ihn erneut ein"
        $NslookupResult = nslookup $ExistingDC
    }

    Write-Host "DNS-Auflösung erfolgreich: $ExistingDC"

    # Installation der AD-Domain-Services
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

    # Konfiguration des neuen Domain Controllers
    $DomainInfo = @{
        DomainName = $DomainName
        NetBIOSName = $NetBIOSName
        SafeModeAdministratorPassword = $SafeModePassword
        ForestMode = $ForestMode
        DomainMode = $DomainMode
    }

    # Ausführung der ADDS-Domäneninstallation
    Install-ADDSDomainController @DomainInfo -InstallDns -Credential $Credential -Force

    # Überprüfung der Replikation
    Write-Host "Überprüfe die Replikation zu den anderen Domain Controllern..."
    $ReplicationStatus = Get-ADReplicationPartnerMetadata -Target $ExistingDC

    # Ausgabe der Replikationsinformationen
    Write-Host "Replikationsstatus:"
    $ReplicationStatus | Format-Table -Property Server, LastReplicationSuccess, LastReplicationAttempt, LastReplicationResult

    # Überprüfung der DNS-Replikation
    Write-Host "Überprüfe die DNS-Replikation..."
    $DnsReplicationStatus = Get-ADReplicationAttributeMetadata -Object "CN=MicrosoftDNS,DC=DomainDnsZones,$DomainName" -Server $ExistingDC

    # Ausgabe der DNS-Replikationsinformationen
    Write-Host "DNS-Replikationsstatus:"
    $DnsReplicationStatus | Format-Table -Property AttributeName, LastOriginatingChangeTime, Version
}
