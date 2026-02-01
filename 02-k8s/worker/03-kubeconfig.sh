#!/usr/bin/env bash

echo "***********************************************************************"
echo "* Copy Kubeconfig                                                     *"
echo "***********************************************************************"
echo

mkdir -p /home/vagrant/.kube
mkdir -p /root/.kube

scp -r root@master01:/root/join-cluster /root
scp root@master01:/root/.kube/config /root/.kube/
