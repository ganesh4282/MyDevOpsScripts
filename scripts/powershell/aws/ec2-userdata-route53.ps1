<#
Description: This script can be placed in windows ec2 userdata to update the instance's private ip address in route53.
Assuming Environment and HostedZone values are provided as parameters in cloudformation or terraform, otherwise replace them with the original value.
#>

$stage = "${Environment}"
$zoneName = "${HostedZone}"

$region = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/dynamic/instance-identity/document | ConvertFrom-Json | Select region).region
$resourceSubDomainName = "$region-$stage"
$hostedZone = Get-R53HostedZones | where Name -eq $zoneName
$resourceName = $resourceSubDomainName + "." + $zoneName
$resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$resourceRecordSet.Name = $resourceName
$resourceRecordSet.Type = "A"
$localip = Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/local-ipv4
$resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ("$localip")
$resourceRecordSet.TTL = 300
$action = [Amazon.Route53.ChangeAction]::UPSERT
$change = New-Object Amazon.Route53.Model.Change ($action, $resourceRecordSet)
Edit-R53ResourceRecordSet -HostedZoneId $hostedZone.Id -ChangeBatch_Change $change
