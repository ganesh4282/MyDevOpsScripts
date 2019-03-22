#!/bin/bash
#Description: This script is used for detaching one instance from Auto Scaling Group. Assuming the ASG name is us-east-1-<application_name> 
#Limiation: This doesnt have any verification step, other than displaying the instance list at the end. This doesnt verify whether the instance is removed from load balancer.


if [ $# != 1 ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo "               Syntax Error: Expected Syntax is, <script>.sh <application_name> "
echo "--------------------------------------------------------------------------------------------------------"
exit 0
fi

#Variables
region=us-east-1

#Function
list_instances () 
{
 echo "The current list of instance(s) from $region-$1 is/are,"
 for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $region-$1 --region $region | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
  do
   privateip=`aws ec2 describe-instances --instance-ids $i --region $region | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | sed -e 's/"//g'`
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
aws autoscaling detach-instances --instance-ids $ins_id --auto-scaling-group-name $region-$1 --region $region --should-decrement-desired-capacity

# Listing back the instances
echo "Detaching the instance..."
sleep 60s
list_instances $1
