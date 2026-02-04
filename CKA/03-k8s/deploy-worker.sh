#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./02-common.sh
source ./worker/03-kubeconfig.sh
source ./worker/04-join.sh
bash
