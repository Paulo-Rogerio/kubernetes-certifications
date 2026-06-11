#!/usr/bin/env bash

echo "#################################################"
echo " This script should be executed on only 1 node.  "
echo "#################################################"

members=("master01" "master02" "master03")

for i in ${members[@]}
do
  if [[ $(hostname -s) == "$i" ]]
  then
    systemctl stop kubelet && rm -rf /var/lib/etcd/* && systemctl status kubelet
  else
    ssh root@$i "systemctl stop kubelet && rm -rf /var/lib/etcd/* && systemctl status kubelet"
  fi

done
