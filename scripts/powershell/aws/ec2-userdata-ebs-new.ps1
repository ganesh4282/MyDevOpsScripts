<#
Description: This script is for formating a raw disk which is attached to the windows server
#>

$newdisk = @(get-disk | Where-Object partitionstyle -eq 'raw')
$Labels = @('Disk2','Disk3','Disk4','Disk5','Disk6')
for($i = 0; $i -lt $newdisk.Count ; $i++)
 {
  $disknum = $newdisk[$i].Number
  $dl = get-Disk $disknum |
  Initialize-Disk -PartitionStyle GPT -PassThru |
  New-Partition -AssignDriveLetter -UseMaximumSize
  Format-Volume -driveletter $dl.Driveletter -FileSystem NTFS -NewFileSystemLabel $Labels[$i] -Confirm:$false
 }
