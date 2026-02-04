#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt upgrade -y
apt list --upgradable
ln -svf /bin/bash /bin/sh
bash
