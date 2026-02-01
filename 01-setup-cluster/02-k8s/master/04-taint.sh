#!/usr/bin/env bash


echo "***********************************************************************"
echo "* Não agenda PODs No Control Plane                                     *"
echo "***********************************************************************"
echo
kubectl taint nodes master-1 node-role.kubernetes.io/control-plane-

