#!/usr/bin/env bash

NAME=$(hostname -s)

rm -rf /etc/kubernetes/pki/etcd/

cp -ra /root/kubeadmcfg-etcd/master01/certs/pki/etcd /etc/kubernetes/pki/

kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml
