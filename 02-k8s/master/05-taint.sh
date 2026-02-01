#!/usr/bin/env bash


echo "***********************************************************************"
echo "* Não agenda PODs No Control Plane                                     *"
echo "***********************************************************************"
echo
nodes=$(kubectl get nodes -o name | awk -F/ '/^node\/master/ {print $2}')

for i in ${nodes[@]}
do
  kubectl taint nodes ${i} node-role.kubernetes.io/control-plane-
done
