#!/usr/bin/env bash

source ./01-env.sh

etcdctl member list --write-out=table
