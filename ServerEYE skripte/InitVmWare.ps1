
param(
    [string]$servername,
    [string]$username,
    [string]$password,
    [string]$domain
)

##################
# Add VI-toolkit #
##################
try{
	$PowerCLIModulePath = “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Modules”
	$OldModulePath = [Environment]::GetEnvironmentVariable(‘PSModulePath’,’Machine’)
	if ($OldModulePath -notmatch “PowerCLI”) {

		$OldModulePath += “;$PowerCLIModulePath”
		[Environment]::SetEnvironmentVariable(‘PSModulePath’,”$OldModulePath”,’Machine’)
	} 

	"Path: $OldModulePath"

			try{
	        . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 
        }catch{

			try{
            . "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1" 

			}catch{
				if (!(Get-Module -Name VMware.VimAutomation.Core) -and (Get-Module -ListAvailable -Name VMware.VimAutomation.Core)) {  
					
					if (!(Import-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {  
						
					 }  
						$Loaded = $True  
					}  
					elseif (!(Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -and !(Get-Module -Name VMware.VimAutomation.Core) -and ($Loaded -ne $True)) {  

						 if (!(Add-PSSnapin -PassThru VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {  

						 }  
				}  
			}
        }
}catch{
	Add-PSsnapin VMware.VimAutomation.Core
}



$passS =[ServerEye.PowerShell.API.PowerShellAPI]::Decrypt($password)

if( [string]::IsNullOrEmpty($domain)){
    connect-VIServer $servername  -User $username -Password $passS -Verbose
}else{
    connect-VIServer $servername  -User $domain\$username -Password $passS -Verbose
}