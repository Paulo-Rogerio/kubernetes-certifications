#!/usr/bin/env bash

echo "#################################################"
echo " This script must be executed on each node       "
echo "#################################################"

export DEBIAN_FRONTEND=noninteractive

apt upgrade -y
apt list --upgradable
ln -svf /bin/bash /bin/sh
