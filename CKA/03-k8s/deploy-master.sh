#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./02-common.sh
source ./master/03-init.sh
source ./master/04-network.sh
source ./master/05-taint.sh
source ./master/06-metallb.sh
source ./master/07-metrics-server.sh
bash
