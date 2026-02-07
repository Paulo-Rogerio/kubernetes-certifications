#!/usr/bin/env bash

cd $(dirname $0)

source ./01-common.sh

[[ $(hostname -s) == "master01" ]] && source ./master/02-vip.sh

source ./master/03-init.sh
source ../deployments/01-cni.sh

[[ $(hostname -s) == "master01" ]] && source ../deployments/02-taint.sh
[[ $(hostname -s) == "master01" ]] && source ../deployments/03-metallb.sh
[[ $(hostname -s) == "master01" ]] && source ../deployments/04-metrics-server.sh

bash
