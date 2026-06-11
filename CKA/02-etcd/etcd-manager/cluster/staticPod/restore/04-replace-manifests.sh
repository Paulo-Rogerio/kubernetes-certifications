#!/usr/bin/env bash

#
# \1 ( Retrovisor ) => Groups the captured item (--initial-cluster=)
# [^"]* => Get anything after = except " that has more than 1 occurrence
#

echo "#################################################"
echo " This script must be executed on each node       "
echo "#################################################"

endpoints="master01=https://10.100.100.11:2380,master02=https://10.100.100.12:2380,master03=https://10.100.100.13:2380"

declare -A members=(
  [10.100.100.11]="master01"
  [10.100.100.12]="master02"
  [10.100.100.13]="master03"
)

for ip in "${!members[@]}";
do
  for name in "${members[$ip]}";
  do
    if [[ "${name}" == "$(hostname -s)" ]]
    then
      mkdir -p /backup
      cp /etc/kubernetes/manifests/etcd.yaml /backup
      sed -i -E "s|(--initial-cluster=)[^\"]*|\1${endpoints}|" /etc/kubernetes/manifests/etcd.yaml
      sed -i -E 's|(--initial-cluster-state=)[^"]*|\1new|' /etc/kubernetes/manifests/etcd.yaml
    fi
  done
done


echo "Start Kubelet...."
systemctl start kubelet
