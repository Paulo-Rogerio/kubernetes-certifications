#!/usr/bin/env bash

kubeadm init phase certs etcd-ca
tree /etc/kubernetes/pki/etcd/
