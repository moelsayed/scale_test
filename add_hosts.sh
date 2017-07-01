#!/bin/bash


if [ $# -lt 1 ]
then
  echo "Usage: $0 number_of_hosts"
  exit 1
fi
count=$1

if [ -z $AWS_EC2_KEY ] || [ -z $AWS_EC2_SECRET_KEY ]
then
  echo "Please set \$AWS_EC2_KEY and \$AWS_EC2_SECRET_KEY"
  exit 1
fi

if [ -z $AWS_EC2_REGION ]
then
  AWS_EC2_REGION=eu-west-2
fi

if [ -z $AWS_EC2_ZONE ]
then
  AWS_EC2_ZONE=b
fi
echo "Running with defaults:"
echo "  \$AWS_EC2_REGION=$AWS_EC2_REGION"
echo "  \$AWS_EC2_ZONE=$AWS_EC2_ZONE"
echo "ctrl-c and export these variables if you need something else."

for i in `seq 1 $count`; 
do
  sleep 5
  hostname=rancher-host-$RANDOM
  echo "Creating $hostname.."
  
  rancher --debug host create --driver amazonec2  --amazonec2-access-key $AWS_EC2_KEY \
    --amazonec2-secret-key $AWS_EC2_SECRET_KEY --amazonec2-security-group rancher-machine \
    --amazonec2-region $AWS_EC2_REGION --amazonec2-zone $AWS_EC2_ZONE  --name $hostname --amazonec2-ami ami-cc7066a8 \
    --amazonec2-instance-type t2.small --engine-install-url=https://releases.rancher.com/install-docker/17.03.sh 
done
