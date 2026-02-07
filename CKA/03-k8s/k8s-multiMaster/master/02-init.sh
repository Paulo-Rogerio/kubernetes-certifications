#!/usr/bin/env bash

set -eo pipefail

export POD_CIDR="10.244.0.0/16"
export SERVICE_CIDR="10.96.0.0/12"
export IP_CONTROL_PLANE="10.100.100.10"
export IP_MASTER1="10.100.100.11"
export IP_MASTER2="10.100.100.12"
export NODENAME=$(hostname -s)
export JOIN_FILE="/root/join-cluster"
export KUBERNETES_VERSION="1.34.3"

function _master01() {
  echo "======================================================"
  echo " Deploy Cluster Master 01                             "
  echo "======================================================"
  echo

  cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${IP_MASTER1}
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
EOF

  kubeadm init --config kubeadm-config.yaml --upload-certs
  rm -f kubeadm-config.yaml

  mkdir -p /root/.kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config

}

function _generate() {
  export TOKEN=$(kubeadm token create)

  export HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
                | openssl rsa -pubin -outform der 2>/dev/null \
                | openssl dgst -sha256 -hex \
                | sed 's/^.* //')

  export CERT=$(kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n1)

  mkdir -p ${JOIN_FILE}

  cat > ${JOIN_FILE}/join.env <<EOF
TOKEN=${TOKEN}
HASH=${HASH}
CERT=${CERT}
EOF

}

function _master() {
  echo "======================================================"
  echo " Deploy Cluster Master 02                             "
  echo "======================================================"
  echo

  cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration

discovery:
  bootstrapToken:
    apiServerEndpoint: "${IP_CONTROL_PLANE}:6443"
    token: "${TOKEN}"
    caCertHashes:
      - "sha256:${HASH}"

controlPlane:
  certificateKey: "${CERT_KEY}"

nodeRegistration:
  name: ${NODENAME}
EOF

  scp -r root@master01:/root/join-cluster /root
  scp root@master01:/root/.kube/config /root/.kube/

  kubeadm join --config kubeadm-config.yaml

  mkdir -p /root/.kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config

}

echo "======================================================"
echo " Pull Images                                          "
echo "======================================================"
echo
kubeadm config images pull

if [[ ${NODENAME} == "master01" ]]
then
  _master01
  _generate

elif [[ ${NODENAME} =~ master0[2-9] ]]
then
  _master
else
  _worker
fi


# mkdir -p ${JOIN_FILE}
# touch ${JOIN_FILE}/join.sh
# chmod +x ${JOIN_FILE}/join.sh
# echo "$(kubeadm token create --print-join-command)" > ${JOIN_FILE}/join.sh
