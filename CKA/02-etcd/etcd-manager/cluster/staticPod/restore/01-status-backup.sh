#!/usr/bin/env bash

echo "#################################################"
echo " This script must be executed on each node       "
echo "#################################################"

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
      if [[ ! -f "/backup/etcd.db" ]] || [[ ! "${name}" == "master03" ]]
      then
        mkdir -p /backup
        scp -r root@master03:/backup/etcd.db /backup/etcd.db
      fi
      etcdutl snapshot status -w table /backup/etcd.db
    fi
  done
done
