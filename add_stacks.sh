#!/bin/bash

log=stacks-`date +%H%M`.log
time_log=time_log-`date +%H%M`.log
too_slow=0
if [ $# -lt 2 ]
then
  echo "Usage: $0 job_name number_of_stacks"
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
  SECONDS=0
  rancher up -d -s nginx-$i | tee -a ../$log
  duration=$SECONDS
  echo "stack-$i $duration" >> $time_log
  if [ $duration -gt 60 ]
  then
    ((too_slow++))
    echo "too_slow=$too_slow"
  elif [ $duration -lt 60 ] && [ $too_slow -gt 0]
  then
    ((too_slow--))
  fi
done
popd

echo "Done. `rancher stack ls -q | wc -l` stacks running. `rancher ps -c | wc -l` containers running."
