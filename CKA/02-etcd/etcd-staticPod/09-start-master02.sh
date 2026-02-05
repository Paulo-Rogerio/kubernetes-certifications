#!/usr/bin/env bash

NAME=$(hostname -s)

mkdir -p /root/kubeadmcfg-etcd

scp -r root@master01:/root/kubeadmcfg-etcd/${NAME}/certs /root/kubeadmcfg-etcd/${NAME}

mkdir -p /etc/kubernetes/pki/etcd/

cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/etcd /etc/kubernetes/pki/

cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/apiserver-etcd-client.{crt,key} /etc/kubernetes/pki/

kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml
