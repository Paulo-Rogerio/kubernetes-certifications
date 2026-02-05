#!/usr/bin/env bash


HOSTS=("master01" "master02")

for i in ${HOSTS[@]}
do
  kubeadm init phase certs etcd-server --config=/root/kubeadmcfg-etcd/${i}/kubeadmcfg.yaml
  kubeadm init phase certs etcd-peer --config=/root/kubeadmcfg-etcd/${i}/kubeadmcfg.yaml
  kubeadm init phase certs etcd-healthcheck-client --config=/root/kubeadmcfg-etcd/${i}/kubeadmcfg.yaml
  kubeadm init phase certs apiserver-etcd-client --config=/root/kubeadmcfg-etcd/${i}/kubeadmcfg.yaml
  mkdir -p /root/kubeadmcfg-etcd/${i}/certs
  cp -R /etc/kubernetes/pki /root/kubeadmcfg-etcd/${i}/certs
  find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete
done
