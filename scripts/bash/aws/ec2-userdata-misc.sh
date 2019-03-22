#!/bin/bash
#Description: This can be used in Ubuntu userdata section to perform below tasks

#Format additional EBS Volume
sudo mkdir /mnt/data 
echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/nvme1n1
sleep 60
sudo mkfs -t ext4 /dev/nvme1n1p1
echo "/dev/nvme1n1p1 /mnt/data ext4 defaults 0 2" | sudo tee --append  /etc/fstab
sudo mount -a

#Attach Existing Volume. Assuming the Volume is tagged as data-volume
instanceid=`curl http://169.254.169.254/latest/meta-data/instance-id`
region=$(curl -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone |  sed 's/[a-z]$//')
VolumeID=$(aws ec2 describe-volumes --filter Name=tag:Name,Values=data-volume --query 'Volumes[*].{ID:VolumeId}' --region $region --output text)
vol_status=$(aws ec2 describe-volumes --volume-ids $VolumeID --query 'Volumes[0].State' --region $region --output text)
if [ "$vol_status" = "available" ]
then
/usr/local/bin/aws ec2 attach-volume --volume-id $VolumeID --instance-id $instanceid --device /dev/sdb --region $region
sleep 10
sudo mount -t ext4 /dev/nvme1n1p1 /mnt
else
echo "Volume is not in available state" > /home/ubuntu/volumestatus
fi

#Install awscli and SSM agent
sudo apt-get -y update
sudo apt install python-pip -y
sudo pip install --upgrade pip
sudo pip install awscli
sleep 90
sudo snap install amazon-ssm-agent --classic
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo snap start amazon-ssm-agent

#Install Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

#Copy a file from S3 bucket
region=$(curl -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone |  sed 's/[a-z]$//')
/usr/local/bin/aws s3 cp s3://config/app.conf --region $region /tmp
sudo /bin/mv /tmp/app.conf /mnt/data/app.conf

#Configure Samba. Assuming samba user password is stored in systems manager - parameter store 
region=$(curl -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone |  sed 's/[a-z]$//')
sudo useradd -m sambauser
SMBpassword=$(/usr/local/bin/aws ssm get-parameters --region $region --names sambauser --with-decryption --query Parameters[0].Value)
SMBpassword=`echo $SMBpassword | sed -e 's/^"//' -e 's/"$//'`
echo "sambauser:$SMBpassword" | chpasswd
sudo apt-get install -y samba    
sleep 120            
echo -e "$SMBpassword\n$SMBpassword\n" | sudo smbpasswd -a -s sambauser
sudo /etc/init.d/samba restart
sudo apt install smbclient -y  

#Some random system level taks
sudo usermod -s /sbin/nologin root
sudo iptables -A INPUT -p tcp --dport 445 -j ACCEPT
