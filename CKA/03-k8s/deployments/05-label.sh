#!/usr/bin/env bash

echo "***********************************************************************"
echo "* Define Label for Workers                                           *"
echo "***********************************************************************"
echo

nodes=$(kubectl get nodes --no-headers | awk '$3 == "<none>" {print $1}')

for i in ${nodes[@]}
do
  kubectl label node ${i} node-role.kubernetes.io/worker=""
done
