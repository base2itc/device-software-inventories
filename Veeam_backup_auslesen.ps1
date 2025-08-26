$JobsOutput = @()


Foreach ($JobObject in Get-VBRJob | ?{$_.JobType -eq "Backup"})
{
$LastSession = $JobObject.FindLastSession()
$JobOutput = New-Object -TypeName PSObject
$JobOutput | Add-Member -Name "Jobname" -MemberType Noteproperty -Value $JobObject.Name
$JobOutput | Add-Member -Name "Endtime" -MemberType Noteproperty -Value $LastSession.endtime
$JobOutput | Add-Member -Name "TotalUsedSize" -MemberType Noteproperty -Value $LastSession.Info.Progress.TotalUsedSize 
$JobOutput | Add-Member -Name "ReadSize" -MemberType Noteproperty -Value $LastSession.Info.Progress.ReadSize
$JobOutput | Add-Member -Name "TransferedSize" -MemberType Noteproperty -Value $LastSession.Info.Progress.TransferedSize
$JobsOutput += $JobOutput
#$JobsOutput
}

$size = $JobsOutput |  Measure-Object -Property TotalUsedSize -Sum 

Write-Host -ForegroundColor Green $size


