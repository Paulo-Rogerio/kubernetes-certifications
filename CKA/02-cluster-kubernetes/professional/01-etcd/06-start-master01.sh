#!/usr/bin/env bash

NAME=$(hostname -s)

rm -rf /etc/kubernetes/pki/etcd/

cp -ra /root/kubeadmcfg-etcd/master01/certs/pki/etcd /etc/kubernetes/pki/

kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml

cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
