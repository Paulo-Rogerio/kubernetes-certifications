#!/usr/bin/env bash

echo "***********************************************************************"
echo "* Definir Label nos Workers                                           *"
echo "***********************************************************************"
echo
node=$(kubectl get nodes --no-headers | awk '$3=="<none>" {print $1}')
kubectl label node ${node} node-role.kubernetes.io/worker=""
