#!/usr/bin/env bash

set -eo pipefail

export POD_CIDR="10.244.0.0/16"
export SERVICE_CIDR="10.96.0.0/12"
export IP_CONTROL_PLANE="10.100.100.11"
export NODENAME=$(hostname -s)
export JOIN_FILE="/root/join-cluster"
export KUBERNETES_VERSION="1.34.3"

echo "======================================================"
echo " Pull Images "
echo "======================================================"
echo
kubeadm config images pull

echo "======================================================"
echo " Deploy Cluster "
echo "======================================================"
echo

cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${IP_CONTROL_PLANE}
  bindPort: 6443
nodeRegistration:
  name: ${NODENAME}
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v${KUBERNETES_VERSION}
controlPlaneEndpoint: "${IP_CONTROL_PLANE}:6443"
apiServer:
  certSANs:
    - "${IP_CONTROL_PLANE}"
networking:
  podSubnet: ${POD_CIDR}
  serviceSubnet: ${SERVICE_CIDR}
etcd:
  external:
    endpoints:
      - https://master01:2379
      - https://master02:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/etcd/etcd.crt
    keyFile: /etc/kubernetes/pki/etcd/etcd.key
EOF


kubeadm init --config kubeadm-config.yaml --upload-certs
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

echo "======================================================"
echo " Generate Script Join Member "
echo "======================================================"
echo

mkdir -p ${JOIN_FILE}
touch ${JOIN_FILE}/join.sh
chmod +x ${JOIN_FILE}/join.sh
echo "$(kubeadm token create --print-join-command)" > ${JOIN_FILE}/join.sh
