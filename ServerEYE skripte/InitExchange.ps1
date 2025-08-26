param(
    [int]$versionInfo,
    [int]$useRemote,
    [string]$servername,
    [string]$username,
    [string]$password,
    [string]$domain,
    [string]$authenticationMethod
)

function Connect-ExchangeServer {


    $computer = $servername
    if( [string]::IsNullOrEmpty($servername)){
        $computer = gc env:computername
    }

    if( [string]::IsNullOrEmpty($authMethod)){
        $authMethod = "Kerberos"
    }


    $passS =[ServerEye.PowerShell.API.PowerShellAPI]::Decrypt($password)
    $securePass = convertto-securestring $passS -asplaintext -force 
    $credential = New-Object System.Management.Automation.PsCredential("$domain\$username",$securePass)


    if($authMethod -eq "Kerberos"){
	    $option =  New-PSSessionOption -IdleTimeout 7200000
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$servername/PowerShell/ -Authentication Kerberos -credential $credential -SessionOption $option 
    }else{
        $option =  New-PSSessionOption -SkipCACheck -SkipCNCheck  -SkipRevocationCheck -IdleTimeout 7200000
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://$servername/PowerShell/ -Authentication Basic -credential $credential -allowredirection -SessionOption $option
    }



    Import-PSSession $Session -AllowClobber

}

##init shell environment!!
if($useRemote -eq 1){
    $s = Get-PSSession | Where-Object {$_.ConfigurationName -eq 'Microsoft.Exchange'}
    $doInit = 1


    if($s){
		$sessions = Get-PSSession |Out-String
		 Write-Host "Sessions: $sessions"
         Write-Host "Exchange Management Shell already loaded"
        $sessState = $s.State
	    
        Write-Host "Current Exchange Session state is: $sessState"

        if($sessState -eq "Opened"){
            $doInit = 0
        }

        

    }
     
    if($doInit -eq 1){
        Get-PSSession
        Get-PSSession | Remove-PSSession
        Write-Host "First cleanup existing sessions, finished"
        $SessionsAfterClean = Get-PSSession |Out-String
		Write-Host "Sessions before cleanup: $SessionsAfterClean"

        Write-Host "Exchange Management Shell not found - Loading..." -ForegroundColor Yellow



        ## . "$env:ExchangeInstallPath\bin\RemoteExchange.ps1"

        Write-Host "Exchange Management Shell loaded $nl"   -ForegroundColor green

         Write-Host "Connecting to Exchange server $nl"

        Connect-ExchangeServer

        Write-Host  "Connected to Exchange Server $nl" -ForegroundColor green
    }
}else{

    if($versionInfo -eq 2007){
            if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue) -eq $null )
            {
                Add-PsSnapin Microsoft.Exchange.Management.PowerShell.Admin
            }
        }

        if($versionInfo -eq 2010){
            if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
            {
                Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
            }
    }
}

if( [string]::IsNullOrEmpty($servername)){
    $servername = gc env:computername
}

$exInfo = Get-ExchangeServer -id $servername

if( $exInfo.AdminDisplayVersion.Major -ne 8){
	Set-AdServerSettings -ViewEntireForest $True 
}
