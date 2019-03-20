#!/bin/bash
#Description: This sctipt is used for providing list of instances which are in particular ASG. Assuming you have multiple profiles configured
if [ $# -lt 3 ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo " Syntax Error: Expected Syntax is, <script>.sh <Profile> <ASG Name> <region>"
echo "--------------------------------------------------------------------------------------------------------"
exit 0
fi 

for i in `aws --profile $1 autoscaling describe-auto-scaling-groups --auto-scaling-group-name $2 --region $3 | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
echo $i
aws --profile $1 ec2 describe-instances --instance-ids $i --region $3 --output text | grep -i PrivateIpAddress | cut -d'	' -f4
done
