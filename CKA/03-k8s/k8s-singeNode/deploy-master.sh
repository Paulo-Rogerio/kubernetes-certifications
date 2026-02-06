#!/usr/bin/env bash

cd $(dirname $0)

echo "======================================="
read -p "Como o Kubernetes ira usar o etcd? (1) ETCD interno. (2) ETCD external : " v

[[ -z ${v} || ! ${v} =~ 1|2 ]] && echo errado && exit 1;

[[ ${v} == 1 ]] && echo "Usando ETCD: Interno" || echo "Usando ETCD: Externo"
echo "======================================="

source ./01-common.sh

[[ ${v} == 1 ]] && source ./master/02-init.sh || source ./master/02-init-external-etcd.sh

source ../deployments/01-cni.sh
source ../deployments/02-taint.sh
source ../deployments/03-metallb.sh
source ../deployments/04-metrics-server.sh
source ../deployments/05-label.sh
bash
