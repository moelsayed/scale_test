#!/bin/bash


if [ $# -lt 2 ]
then
  echo "Usage: $0 job_name number_of_stacks"
  exit 1
fi
log=$1_stacks-`date +%H%M`.log
time_log=$1_time_log-`date +%H%M`.log
api_time_log=$1_api_time_log-`date +%H%M`.log
too_slow=0
count=$2

if [ ! -e nginx/docker-compose.yml ] || [ ! -e nginx/rancher-compose.yml ]
then
  echo "Can't find stack files"
  exit 1
fi

pushd nginx

for i in `seq 1 $count`
do
  if [ $too_slow -gt 5 ]
  then
    echo "That's it."
    exit 1
  fi
  SECONDS=0
  rancher up -d -s nginx-$i | tee -a ../$log
  duration=$SECONDS
  echo $duration
  echo "`date "+%F %T"` stack-$i $duration" >> ../$time_log
  if [ $duration -gt 60 ]
  then
    ((too_slow++))
    echo "too_slow=$too_slow"
  elif [ $duration -lt 60 ] && [ $too_slow -gt 0 ]
  then
    ((too_slow--))
  fi

  SECONDS=0
  rancher stack ls -q > /dev/null
  stack_ls_duration=$SECONDS

  SECONDS=0
  rancher ps -c  > /dev/null
  container_ls_duration=$SECONDS

  echo "`date "+%F %T"` stack-$i $duration  $stack_ls_duration $container_ls_duration" >> ../$api_time_log

done
popd

echo "Done. `rancher stack ls -q | wc -l` stacks running. `rancher ps -c | wc -l` containers running."
