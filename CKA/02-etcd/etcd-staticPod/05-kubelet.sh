#!/usr/bin/env bash

# Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# Replace the value of "containerRuntimeEndpoint" for a different container runtime if needed.
#
# Using cgroupDriver: systemd is the recommendation for this 3-member etcd scenario.
# This is because systemd is the operating system's boot manager
# and the person responsible for allocating the cgroup tree for services.
# If set to cgroupfs, Kubelet will attempt to manage cgroups directly,
# generating a competitive conflict with systemd for control of the machine's resources.

echo "#################################################"
echo " This script must be executed on each node       "
echo "#################################################"

mkdir -p /etc/systemd/system/kubelet.service.d/

cat << EOF > /etc/systemd/system/kubelet.service.d/kubelet.conf

apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: false
authorization:
  mode: AlwaysAllow
cgroupDriver: systemd
address: 127.0.0.1
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
staticPodPath: /etc/kubernetes/manifests
EOF

cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
ExecStart=/usr/bin/kubelet --config=/etc/systemd/system/kubelet.service.d/kubelet.conf
Restart=always
EOF

cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

systemctl daemon-reload
systemctl restart kubelet
