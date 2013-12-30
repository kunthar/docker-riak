#! /bin/bash

set -e

if sudo docker ps | grep "kunthar/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

for index in `seq 5`;
do
  CONTAINER_ID=$(sudo docker run -d -i \
    -h "riak${index}" \
    -e "RIAK_NODE_NAME=34.34.34.${index}0" \
    -t "kunthar/riak")

  sleep 1
	
  sudo ./bin/pipework br1 ${CONTAINER_ID} "34.34.34.${index}0/24@34.34.34.1"

  echo "Container id is ${CONTAINER_ID}"
  echo "Started [riak${index}] and assigned it the IP [34.34.34.${index}0]"

  if [ "$index" -eq "1" ] ; then
    sudo ifconfig br1 34.34.34.254

    sleep 1
  fi

  until curl -s "http://34.34.34.${index}0:8098/ping" | grep "OK" >/dev/null;
  do
    echo "curl to http://34.34.34.${index}0:8098/ping"
    sleep 1
  done

  if [ "$index" -gt "1" ] ; then

    #echo "Setting riak config params"
    #sshpass -p "basho" \
    #  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@34.34.34.${index}0 \
    #    sudo /bin/bash /provision.sh
    
    #sleep 1

    echo "Requesting that [riak${index}] join the cluster.."

    sshpass -p "basho" \
      ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@34.34.34.${index}0 \
        riak-admin cluster join riak@34.34.34.10
  fi
done

sleep 5

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@34.34.34.10 \
    riak-admin cluster plan

read -p "Commit these cluster changes? (y/n): " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@34.34.34.10 \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@34.34.34.10 \
      riak-admin cluster clear
fi
