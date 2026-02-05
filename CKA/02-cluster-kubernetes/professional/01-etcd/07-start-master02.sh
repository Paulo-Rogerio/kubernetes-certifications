#!/usr/bin/env bash

NAME=$(hostname -s)

mkdir -p /root/kubeadmcfg-etcd

scp -r root@master01:/root/kubeadmcfg-etcd/${NAME}/certs /root/kubeadmcfg-etcd/${NAME}

mkdir -p /etc/kubernetes/pki/etcd/

cp -ra /root/kubeadmcfg-etcd/${NAME}/certs/pki/etcd /etc/kubernetes/pki/

kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml


cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
