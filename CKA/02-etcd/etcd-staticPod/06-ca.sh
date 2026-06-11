#!/usr/bin/env bash

echo "####################################################"
echo " This script must be executed only in node master01 "
echo "####################################################"


kubeadm init phase certs etcd-ca
tree /etc/kubernetes/pki/etcd/
