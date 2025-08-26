<# Normal PowerShell Init-Script, that tries to load some snap-ins#>

param(
    [int]$useRemote,
    [string]$user,
	[string]$pass,
	[string]$domain,
    [string]$servername
)

function Connect-RemoteServer {

    #$passS =[ServerEye.PowerShellAPI]::Decrypt($pass)
    $securePass = convertto-securestring $pass -asplaintext -force 
    $credential = New-Object System.Management.Automation.PsCredential("$domain\$user",$securePass)
    $Session = New-PSSession -ComputerName $servername -ErrorAction Stop -Authentication Kerberos -credential $credential
    Invoke-Command $Session -ScriptBlock {Import-Module -Name "Hyper-V" -ErrorAction Continue  }
    Invoke-Command $Session -ScriptBlock { if((Get-Module -Name "Hyper-V")){  "Hyper-V loaded"}else{ "Hyper-V not loaded"}}
	Invoke-Command $Session -ScriptBlock {Import-Module -Name "failoverclusters" -ErrorAction Continue  }
    Invoke-Command $Session -ScriptBlock { if((Get-Module -Name "failoverclusters")){  "Hyper-V Cluster loaded"}else{ "Hyper-V Cluster not loaded"}}
    Invoke-Command $Session -ScriptBlock {Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Continue }
    Invoke-Command $Session -ScriptBlock { if(get-pssnapin "Microsoft.SharePoint.PowerShell" -ea "silentlycontinue") {  "Sharepoint loaded"}else{ "Sharepoint not loaded"}}

                    
    Import-PSSession $Session -Module "failoverclusters" -ErrorAction Continue

}

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
} #end function get-MyModule 

##init shell environment!!
if($useRemote -eq 1){
     Write-Host "Connecting to Remote server $nl"

    Connect-RemoteServer

     Write-Host "Connected to Remote Server $nl" -ForegroundColor green

}else{
    #load the stuff locally
    $hyperVSnap="failoverclusters"

	if(Get-MyModule -name $hyperVSnap){
         Write-Host "Hyper-V Cluster Snapin loaded"
	}else{
		 Write-Host "Hyper-V Cluster Snapin not loaded/found"
		 Import-Module -Name "failoverclusters" -ErrorAction SilentlyContinue 
	}

	$hyperV="Hyper-V"

	if(Get-MyModule -name $hyperV){
         Write-Host "Hyper-V Snapin loaded"
	}else{
		 Write-Host "Hyper-V Snapin not loaded/found"
		 Import-Module -Name "Hyper-V" -ErrorAction SilentlyContinue 
	}

    $sharepointSnap = "Microsoft.SharePoint.PowerShell"

    if (get-pssnapin $sharepointSnap -ea "silentlycontinue") {
         Write-Host "PSsnapin $sharepointSnap is loaded"
    }
    elseif (get-pssnapin $sharepointSnap -registered -ea "silentlycontinue") {
         Write-Host "PSsnapin $sharepointSnap is registered but not loaded"
        Add-PSSnapin $sharepointSnap
    }
    else {
        Write-Host  "PSSnapin $sharepointSnap not registered"
    }

	$rdp="RemoteDesktop"

	if(Get-MyModule -name $rdp){
         Write-Host "RDP Module loaded"
	}else{
		 Write-Host "RDP Module not loaded/found"
		 Import-Module -Name "RemoteDesktop" -ErrorAction SilentlyContinue 
	}
}






