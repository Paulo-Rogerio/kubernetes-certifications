#!/usr/bin/env bash

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
      etcdutl snapshot restore /backup/etcd.db \
        --name ${name} \
        --initial-cluster "${endpoints}" \
        --initial-advertise-peer-urls https://${ip}:2380 \
        --data-dir /var/lib/etcd
    fi
  done
done
