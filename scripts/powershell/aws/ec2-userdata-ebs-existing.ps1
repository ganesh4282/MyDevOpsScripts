<#
Description: This script is for attaching exising EBS volume to the windows server
#>

$region = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/dynamic/instance-identity/document | ConvertFrom-Json | Select region).region
$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id 
$volume = "${Vol1}"
if ( ((Get-EC2Volume -VolumeId $volume -Region $region).state -eq 'in-use') )
   {
      Write-Host "Disk is in use state"
   }
   Else
   {
      Add-EC2Volume -instanceId $instanceId -VolumeId $volume -Device xvdb -Region $region
      Start-Sleep 15
      Get-Disk | Where-Object IsOffline -Eq $True | Set-Disk -IsReadonly $False
      Get-Disk | Where-Object IsOffline -Eq $True | Set-Disk -IsOffline $False
      Write-Host "Disk has been attached successfully."
   }
