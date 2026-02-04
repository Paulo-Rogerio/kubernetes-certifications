#!/usr/bin/env bash

apt upgrade -y
apt list --upgradable
ln -svf /bin/bash /bin/sh
