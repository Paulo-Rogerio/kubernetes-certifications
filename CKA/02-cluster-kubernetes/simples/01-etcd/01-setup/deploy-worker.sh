#!/usr/bin/env bash

cd $(dirname $0)

source ./01-upgrade.sh
source ./03-install.sh
source ./04-certs.sh
source ./05-startup.sh
