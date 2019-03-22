#!/bin/bash
#Description: This can be used in Ubuntu userdata section for registering private and public ip addresses 

#Update Private IP in Route53. This needs hosted zone detail.
HZ=example.com.
hostedzoneid=$(aws route53 list-hosted-zones-by-name --dns-name $HZ --query 'HostedZones[0].Id' | cut -d / -f 3 | tr -d '"')
localip=$(curl -fs http://169.254.169.254/latest/meta-data/local-ipv4)
> /home/ubuntu/.myrecordset.json
prifile=/home/ubuntu/.myrecordset.json
cat << EOF >> $prifile
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": mylab-pri-rr.$HZ",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$localip"
          }
        ]
      }
    }
  ]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$prifile

#Update Public IP in Route53.
HZ=example.com.
hostedzoneid=$(aws route53 list-hosted-zones-by-name --dns-name $HZ --query 'HostedZones[0].Id' | cut -d / -f 3 | tr -d '"')
publicip=$(curl -fs http://169.254.169.254/latest/meta-data/public-ipv4)
> /home/ubuntu/.myrrset.json
pubfile=/home/ubuntu/.myrrset.json
cat << EOF >> $pubfile
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": mylab-pub-rr.$HZ",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$publicip"
          }
        ]
      }
    }
  ]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$pubfile
