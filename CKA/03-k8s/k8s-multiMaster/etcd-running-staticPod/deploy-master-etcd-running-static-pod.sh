#!/usr/bin/env bash

cd $(dirname $0)

source ./master/02-init.sh
source ./master/03-network.sh
source ./master/04-taint.sh
source ./master/05-metallb.sh
source ./master/06-metrics-server.sh
bash
