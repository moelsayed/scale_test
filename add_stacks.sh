#!/bin/bash

log=stacks-`date +%H%M`.log

if [ $# -lt 1 ]
then
  echo "Usage: $0 number_of_stacks"
  exit 1
fi
count=$1

if [ ! -e nginx/docker-compose.yml ] || [ ! -e nginx/rancher-compose.yml ]
then
  echo "Can't find stack files"
  exit 1
fi

pushd nginx

for i in `seq 1 $count`
do
  rancher up -d -s nginx-$RANDOM | tee -a ../$log
done 
popd 

echo "Done. `rancher stack ls -q | wc -l` stacks running. `rancher ps -c | wc -l` containers running."
