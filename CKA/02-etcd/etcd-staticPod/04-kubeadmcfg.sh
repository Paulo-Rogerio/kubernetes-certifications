#!/usr/bin/env bash

declare -A members=(
  [10.100.100.11]="master01"
  [10.100.100.12]="master02"
)

for ip in "${!members[@]}";
do
  for name in "${members[$ip]}";
  do
    mkdir -p /root/kubeadmcfg-etcd/${name}
    cat << EOF > /root/kubeadmcfg-etcd/${name}/kubeadmcfg.yaml
---
apiVersion: "kubeadm.k8s.io/v1beta4"
kind: InitConfiguration
nodeRegistration:
 name: ${name}
localAPIEndpoint:
 advertiseAddress: ${ip}
---
apiVersion: "kubeadm.k8s.io/v1beta4"
kind: ClusterConfiguration
etcd:
 local:
    serverCertSANs:
    - "${ip}"
    peerCertSANs:
    - "${ip}"
    extraArgs:
    - name: initial-cluster
      value: master01=https://10.100.100.11:2380,master02=https://10.100.100.12:2380
    - name: initial-cluster-state
      value: new
    - name: name
      value: ${name}
    - name: listen-peer-urls
      value: https://${ip}:2380
    - name: listen-client-urls
      value: https://${ip}:2379
    - name: advertise-client-urls
      value: https://${ip}:2379
    - name: initial-advertise-peer-urls
      value: https://${ip}:2380
EOF

  done
done
