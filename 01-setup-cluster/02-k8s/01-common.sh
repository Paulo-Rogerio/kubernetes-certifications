#!/usr/bin/env bash

set -eo pipefail

export DEBIAN_FRONTEND=noninteractive
export KUBERNETES_SHORT_VERSION="1.34"
export IP_CONTROL_PLANE="10.100.100.10"
export TIMEZONE="America/Sao_Paulo"

# Doc
# https://v1-34.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Disable Swap
echo "======================================================"
echo " Disable Swap "
echo "======================================================"
echo
swapoff -a
sed -i '/swap.img/d' /etc/fstab
timedatectl set-timezone ${TIMEZONE}

# Keyrings Containerd
echo "======================================================"
echo " Keyrings Containerd "
echo "======================================================"
echo
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y gpg

# helm install
echo "======================================================"
echo " Helm Install"
echo "======================================================"
echo
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod +x /tmp/get_helm.sh
bash /tmp/get_helm.sh
rm -f /tmp/get_helm.sh

# repo kubeadmn
echo "======================================================"
echo " Repo Kubeadm "
echo "======================================================"
echo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_SHORT_VERSION}/deb/Release.key | \
 gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_SHORT_VERSION}/deb/ /" | \
 tee /etc/apt/sources.list.d/kubernetes.list

# Install packages
echo "======================================================"
echo " Install Packages "
echo "======================================================"
echo
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release containerd bash-completion

# config containerd
echo "======================================================"
echo " Containerd Modulos "
echo "======================================================"
echo
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
echo "======================================================"
echo " Configure Kernel "
echo "======================================================"
echo
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

echo "======================================================"
echo " Install Kubernetes "
echo "======================================================"
echo
echo "apt-get install -y kubelet kubectl kubeadm"
apt-get install -y kubelet kubectl kubeadm
apt-mark hold kubelet kubeadm kubectl

echo "======================================================"
echo " Configure Containerd "
echo "======================================================"
echo
# Listar as imagens usadas
# kubeadm config images list --kubernetes-version v1.34.0
imagem_pause=$(kubeadm config images list --kubernetes-version v${KUBERNETES_SHORT_VERSION}.0 | grep 'pause' | awk -F/ '{print $NF}')

echo "containerd config default > /etc/containerd/config.toml"
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i "s/pause:3.8/${imagem_pause}/" /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd --now
systemctl restart containerd 

echo "======================================================"
echo " Start Kubelet "
echo "======================================================"
echo
#
# Se tem mais de uma Interface , deve-se anunciar ao Kubelet qual IP respondera as requisicoes
#
echo "systemctl restart kubelet"
sed -i "/Environment=/a Environment="KUBELET_EXTRA_ARGS=--node-ip=${IP_CONTROL_PLANE}"" /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

echo "======================================================"
echo " Container Runtime Configured Successfully "
echo "======================================================"
echo
