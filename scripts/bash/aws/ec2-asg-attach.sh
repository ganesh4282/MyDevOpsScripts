#!/bin/bash
#Description: This script is used for attaching an instance to Auto Scaling Group. Assuming the ASG name is us-east-1-<application_name>

if [ $# != 1 ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo "               Syntax Error: Expected Syntax is, <script>.sh <ASG Name ex. recorder|web> "
echo "--------------------------------------------------------------------------------------------------------"
exit 0
fi

#Variables
region=us-east-1

list_instances ()
{
 for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $region-$1 --region $region | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
  do
   privateip=`aws ec2 describe-instances --instance-ids $i --region $region | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | sed -e 's/"//g'`
   echo -e "\n"
   echo $i
   echo $privateip
   echo "-------------------"
  done
}

#Listing the instances to choose
echo " Here are the current list of instances which are in auto scaling group : "
list_instances $1

#Attaching the instance
echo "Enter the instance id which you want to attach:"
read ins_id

#Compare and attach the instance
ins_count=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $region-$1 --region $region | grep -i instanceid | grep -i $ins_id | wc -l`
if [ $ins_count -eq 0 ]; then
 echo "Attaching the instance..."
 aws autoscaling attach-instances --instance-ids $ins_id --auto-scaling-group-name $region-$1 --region $region
 sleep 30s
 echo " Here are the updated current list of instances in auto scaling group :"
 list_instances $1
else
 echo " Please verify the instance id & re-run the script with a valid instance id "
fi
