#!/usr/bin/env bash

set -eo pipefail

export POD_CIDR="10.244.0.0/16"
export SERVICE_CIDR="10.96.0.0/12"
export IP_CONTROL_PLANE="10.100.100.10"
export NODENAME=$(hostname -s)
export JOIN_FILE="/root/join-cluster"

echo "======================================================"
echo " Pull Images "
echo "======================================================"
echo
kubeadm config images pull

echo "======================================================"
echo " Pull Images "
echo "======================================================"
echo
kubeadm init \
  --apiserver-advertise-address=${IP_CONTROL_PLANE} \
  --apiserver-cert-extra-sans=${IP_CONTROL_PLANE} \
  --pod-network-cidr=${POD_CIDR} \
  --service-cidr=${SERVICE_CIDR} \
  --node-name ${NODENAME} 

mkdir -p /home/vagrant/.kube
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p ${JOIN_FILE}
touch ${JOIN_FILE}/join.sh
chmod +x ${JOIN_FILE}/join.sh       
echo "$(kubeadm token create --print-join-command)" > ${JOIN_FILE}/join.sh
