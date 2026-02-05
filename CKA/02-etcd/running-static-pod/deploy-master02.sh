#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./02-common.sh
source ./03-etcdctl.sh
source ./04-kubeadmcfg.sh
source ./05-kubelet.sh
source ./09-start-master02.sh

echo "Aguarde Start Static Pod..."
sleep 20
crictl ps
