#!/usr/bin/env bash

cd $(dirname $0)

openssl x509 -in certs/etcd.pem -text
