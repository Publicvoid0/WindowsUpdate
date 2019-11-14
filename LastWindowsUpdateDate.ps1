$servers = Get-ADComputer -Filter {(OperatingSystem -like "* server *") -and (Enabled -eq "True")} -Properties OperatingSystem | Sort Name | select -Unique Name

foreach ($server in $servers) {

$PingResult = Get-WmiObject -Query "SELECT * FROM win32_PingStatus WHERE address='$($server.Name)'" 
   
  If ($PingResult.StatusCode -eq 0)  
  { 
# This line has been commented out since is not always correctly reporting on updates that were installed from other sources that do not use WindowsUpdate Service e.g.: Symantec Altiris
# However it is quicker to run than the current format 
# $result =  Invoke-Command -ComputerName $server.Name -ScriptBlock {(New-Object -com "Microsoft.Update.AutoUpdate").Results}
# Write-Output $result | Format-Table 
$lastpatch = Get-WmiObject -ComputerName $server.Name Win32_Quickfixengineering | select @{Name="InstalledOn";Expression={$_.InstalledOn -as [datetime]}} | Sort-Object -Property Installedon | select-object -property installedon -last 1
$result = Get-Date $lastpatch.InstalledOn -format yyyy-MM-dd
Write-output "$($server.name),$($result)"
}
else{ 
Write-Output "$($server.name) , OFFLINE"
}
}
