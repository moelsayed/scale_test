#!/bin/bash


if [ $# -lt 2 ]
then
  echo "Usage: $0 job_name number_of_stacks"
  exit 1
fi
log=$1_stacks-`date +%H%M`.log
time_log=$1_time_log-`date +%H%M`.log
api_time_log=$1_api_time_log-`date +%H%M`.log
per_request_log=$1_per_request_log-`date +%H%M`.log
avg_request_log=$1_per_request_log-`date +%H%M`.log
too_slow=0
count=$2
host_list=`rancher hosts --format '{{.Host.AgentIpAddress }}'`
host_count=`echo $host_list | wc -w`

global_service=1

if [ ! -e nginx/docker-compose.yml ] || [ ! -e nginx/rancher-compose.yml ]
then
  echo "Can't find stack files"
  exit 1
fi

pushd nginx

for i in `seq 1 $count`
do
  # check if we hit the slow reposne limit
  if [ $too_slow -ge 5 ]
  then
    echo "That's it."
    exit 1
  fi

  # add a new stack, count seconds and log
  SECONDS=0
  rancher up -d -s nginx-$i | tee -a ../$log
  duration=$SECONDS
  echo $duration
  echo "`date "+%F %T"` stack-$i $duration" >> ../$time_log

  # check if the stack too longer than it should.
  # increment the slow couner if it did
  if [ $duration -gt 60 ]
  then
    ((too_slow++))
    echo "too_slow=$too_slow"
  # decrement the counter to account for outliers. 
  elif [ $duration -lt 60 ] && [ $too_slow -gt 0 ]
  then
    ((too_slow--))
  fi

  # check api reponse times and log.
  SECONDS=0
  rancher stack ls -q > /dev/null
  stack_ls_duration=$SECONDS

  SECONDS=0
  rancher ps -c  > /dev/null
  container_ls_duration=$SECONDS

  echo "`date "+%F %T"` stack-$i $duration  $stack_ls_duration $container_ls_duration" >> ../$api_time_log

  # check the global service reponse time.
  if [ $global_service -eq 1 ]
  then
    total_duration=0
    failed=0
    for host in host_list
    do 
      SECONDS=0
      curl -s -f http://$host/ 2>&1 > /dev/null
      s=$?
      req_duration=$SECONDS
      
      if [ $s -ne 0 ]
      then
        ((failed++))
      fi
      
      echo "`date "+%F %T"` stack-$i $host $req_duration $s" >> ../$per_request_log
      let total_duration=$total_duration+$req_duration
    done
    
    let avg_duration=$total_duration/$host_count
    echo "`date "+%F %T"` stack-$i $avg_duration $failed" >> ../$avg_request_log 

  fi
done
popd

echo "Done. `rancher stack ls -q | wc -l` stacks running. `rancher ps -c | wc -l` containers running."
