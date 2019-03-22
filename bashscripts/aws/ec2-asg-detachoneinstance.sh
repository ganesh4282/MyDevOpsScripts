#!/bin/bash
#Description: This script is to detach one instance from Auto Scaling Group. Assuming the ASG name is us-east-1-<application_name> 
if [ $# != 1 ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo "               Syntax Error: Expected Syntax is, <script>.sh <application_name> "
echo "--------------------------------------------------------------------------------------------------------"
exit 0
fi

list_instances () 
{
 echo "The current list of instance(s) from us-east-1-$1 is/are,"
 for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name us-east-1-$1 --region us-east-1 | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
  do
   privateip=`aws ec2 describe-instances --instance-ids $i --region us-east-1 | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | sed -e 's/"//g'`
   echo -e '\n'
   echo $i
   echo $privateip
   echo "-------------------"
  done
}

# Listing the instances to choose
list_instances $1

# Terminating the instances
echo "Enter the instance which needs to be terminated :"
read ins_id
aws autoscaling detach-instances --instance-ids $ins_id --auto-scaling-group-name us-east-1-$1 --should-decrement-desired-capacity

# Listing back the instances
echo "Detaching the instance..."
sleep 60s
list_instances $1
