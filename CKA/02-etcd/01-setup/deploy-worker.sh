#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./02-install.sh
source ./05-start-worker.sh
