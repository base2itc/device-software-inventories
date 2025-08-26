param(
    [string]$username,
    [string]$password,
    [string]$domain,
    [string]$authenticationMethod,
	[int]$useOffice365Germany
)

Function Get-MyModule 
{ 
	Param([string]$name) 
	if(-not(Get-Module -name $name)) 
	{ 
		if(Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) 
		{ 
			Import-Module -Name $name 
			$true 
		} #end if module available then import 
		else { $false } #module not available 
	} # end if not module 
	else { $true } #module already loaded 
}

Function Connect-Office365 {

	if( [string]::IsNullOrEmpty($authMethod)){
			$authMethod = "Basic"
	}

	$passS =[ServerEye.PowerShell.API.PowerShellAPI]::Decrypt($password)
    $securePass = convertto-securestring $passS -asplaintext -force 
    $credential = New-Object System.Management.Automation.PsCredential($username,$securePass)
	$timeoutOpt = New-PSSessionOption -IdleTimeout 300000

	 if($useOffice365Germany -eq 1){
		 Write-Host "Office 365 Germany is used"
		 $office365= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office.de/powershell-liveid/  -Credential $credential -Authentication Basic  –AllowRedirection -SessionOption $timeoutOpt
	 }else{
		 Write-Host "Office 365 US is used"
		 Write-Host "$useOffice365Germany"
		$office365= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic  –AllowRedirection -SessionOption $timeoutOpt
	}

	Import-PSSession $office365 -AllowClobber

}


Write-Host "Connecting to Office365 server $nl"

Connect-Office365

Write-Host  "Connected to Office365 Server $nl" -ForegroundColor green

 $msonline="MSOnline"

if(Get-MyModule -name $msonline){
    Write-Host "MSOnline Snapin loaded"
}else{
	Write-Host "MSOnline Snapin not loaded/found"
	Import-Module -Name "MSOnline" -ErrorAction SilentlyContinue 
}

try{
	$passS =[ServerEye.PowerShell.API.PowerShellAPI]::Decrypt($password)
    $securePass = convertto-securestring $passS -asplaintext -force 
    $credential = New-Object System.Management.Automation.PsCredential("$username",$securePass)

	 if($useOffice365Germany -eq 1){
		Connect-MsolService -AzureEnvironment AzureGermanyCloud -Credential $credential 
	}else{
		Connect-MsolService -Credential $credential 
	}

	
	
	$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $credential -Authentication Basic -AllowRedirection 
	Import-PSSession $session -AllowClobber   

}catch{

}

try{
	$module = "ExchangeOnlineManagement"

	if(Get-MyModule -name $module){
		Write-Host "Exchange Online Snapin loaded"
	}else{
		Write-Host "Exchange Online not loaded/found"
		Import-Module -Name $module -ErrorAction SilentlyContinue 
	}

	$passS =[ServerEye.PowerShell.API.PowerShellAPI]::Decrypt($password)
    $securePass = convertto-securestring $passS -asplaintext -force 
    $credential = New-Object System.Management.Automation.PsCredential($username,$securePass)

	 if($useOffice365Germany -eq 1){
		$exOnline = Connect-ExchangeOnline –Credential $credential -ConnectionUri https://outlook.office.de/PowerShell-LiveID -AzureADAuthorizationEndPointUri https://login.microsoftonline.de/common
	}else{
		$exOnline = Connect-ExchangeOnline –Credential $credential
	}

	Import-PSSession $exOnline -AllowClobber   
}catch{

}



