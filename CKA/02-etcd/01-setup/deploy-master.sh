#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./02-install.sh
source ./03-certs.sh
source ./04-start-master.sh
