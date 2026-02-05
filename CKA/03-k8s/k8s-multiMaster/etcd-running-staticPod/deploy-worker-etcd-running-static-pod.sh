#!/usr/bin/env bash

cd $(dirname $0)

source ./worker/02-kubeconfig.sh
source ./worker/03-join.sh
bash
