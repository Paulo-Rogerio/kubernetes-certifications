#!/usr/bin/env bash

NAME=$(hostname -s)

kubeadm init phase etcd local --config=/root/kubeadmcfg-etcd/${NAME}/kubeadmcfg.yaml

echo "Sleep 10..."
sleep 10

crictl ps
