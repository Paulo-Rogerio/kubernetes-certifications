#!/usr/bin/env bash

cd $(dirname $0)

source ./01-common.sh
source ./master/02-init.sh
source ../deployments/01-cni.sh
source ../deployments/02-taint.sh
source ../deployments/03-metallb.sh
source ../deployments/04-metrics-server.sh
source ../deployments/05-label.sh
bash
