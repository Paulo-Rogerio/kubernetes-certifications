#!/usr/bin/env bash

echo "#################################################"
echo " This script must be executed on each node       "
echo "#################################################"


NAME=$(hostname -s)

mkdir -p /etc/kubernetes/pki/etcd/

if [[ ${NAME} == "master01" ]]
then
  cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/etcd /etc/kubernetes/pki/
  cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/apiserver-etcd-client.{crt,key} /etc/kubernetes/pki/
  kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml

else
  mkdir -p /root/kubeadmcfg-etcd
  scp -r root@master01:/root/kubeadmcfg-etcd/${NAME}/certs /root/kubeadmcfg-etcd/${NAME}
  cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/etcd /etc/kubernetes/pki/
  cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/apiserver-etcd-client.{crt,key} /etc/kubernetes/pki/
  kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml
fi
