#!/usr/bin/env bash

source /root/etcdctl.env

etcdctl member add master03 --peer-urls=https://master03:2380
