#!/usr/bin/env bash

echo "***********************************************************************"
echo "* Join Member Cluster                                                 *"
echo "***********************************************************************"
echo

sh /root/join-cluster/join.sh

function check_pod_running(){
    todo=true
    while ${todo};
    do
      podsWorking=$(kubectl get pod -A -o custom-columns="STATUS:.status.phase" | grep -v STATUS | egrep -vc "Running|Succeeded")
      [[ ${podsWorking} == 0 ]] && export todo=false
      echo "Waiting Pod Health..."
      sleep 10
    done
    echo "Pods Running"
}

check_pod_running

echo "***********************************************************************"
echo "* Member Add                                                          *"
echo "***********************************************************************"
echo
