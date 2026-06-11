# 🚀 Learn K8S

- [1) Vms Requirements](#1-vms-requirements)
- [2) Vms Startup](#2-vms-startup)
- [3) Deploy Kubernetes Multi Master](#3-deploy-kubernetes-multi-master)
- [4) Cluster Information](#4-cluster-information)


## 1) Vms Requirements

To run this lab it is necessary to have **KVM**installed on the host, as it will emulate all the necessary vms.

#### ImagesCloud

It is necessary to download the image in **qcow2**format, which is already adapted to run with cloud-init. [Official Download](https://cloud-images.ubuntu.com/).

#### Image Directory

This script assumes that the images must be located in **/var/lib/libvirt/images/**.

#### SSH key
It is necessary to have a modern and secure SSH key pair of type **id_ed25519**(private and public), based on the Ed25519 algorithm for passwordless authentication on servers.

```bash
ssh-keygen -t ed25519 -C "seu_email@exemplo.com"
```

#### Add Entries to your /etc/hosts

This will help a lot with SSH connection

```bash
# Studies Cka
#==============================
10.100.100.10       vip
10.100.100.11       master01
10.100.100.12       master02
10.100.100.13       master03
10.100.100.20       worker01
```

#### Password Default

All VMs have a default password already defined in cloud-init **123456**.

## 2) Vms Startup

[Clone the Repository](https://github.com/Paulo-Rogerio/kubernetes-certifications.git), and navigate to the **01-kvm**directory. In this directory, you will find a **hosts.txt**file, which will define the number of hosts your laboratory will have.

```bash
#===========================================================================
# Learning K8S
#===========================================================================
# Vm Name  |  Ram  | vCPU  |     Ip        |   Imagem Cloud Init
#===========================================================================
master01     2048     3      10.100.100.11   jammy-server-cloudimg-amd64.img
master02     2048     3      10.100.100.12   jammy-server-cloudimg-amd64.img
worker01     2048     3      10.100.100.20   jammy-server-cloudimg-amd64.img
#===========================================================================
# Learning ETCD
#===========================================================================
# master01   2048     3      10.100.100.11    jammy-server-cloudimg-amd64.img
# master02   2048     3      10.100.100.12    jammy-server-cloudimg-amd64.img
# master03   2048     3      10.100.100.13    jammy-server-cloudimg-amd64.img
```

The installer already guarantees that this network will be created, so **DO NOT**change the range **10.100.100.**. This network is created in **NAT**mode, to avoid any type of conflict.

#### Starting Vms

This utility already creates all the necessary requirements.

```bash
sh deploy.sh
```

Connect to the newly created VM.

```bash
ssh root@master01
```

#### Removing Vms

Remove the Vms after the lab is finished.

```bash
sh remove.sh
```

## 3) Deploy Kubernetes Single Master

After deploying the Vms, connect to (**master01, master02 and worker01**).

This implementation will deploy the internal **etcd**, maintained and managed by **kubelet**.


```bash
ssh root@master01
cd /root/kubernetes-certifications/CKA/03-k8s/multiMaster
bash deploy.sh

kubectl get nodes

NAME       STATUS   ROLES           AGE     VERSION
master01   Ready    control-plane   47s   v1.34.4
```

After deploying **master01**, connect to **master02**and perform a similar procedure.

```bash
ssh root@master02
cd /root/kubernetes-certifications/CKA/03-k8s/multiMaster
bash deploy.sh
kubectl get nodes

NAME       STATUS   ROLES           AGE     VERSION
master01   Ready    control-plane   3m58s   v1.34.4
master02   Ready    control-plane   23s     v1.34.4
```

After deploying the **masters**, connect to **worker01**and perform a similar procedure.

```bash
ssh root@worker01
cd /root/kubernetes-certifications/CKA/03-k8s/multiMaster
bash deploy.sh
kubectl get nodes

NAME       STATUS   ROLES           AGE     VERSION
NAME       STATUS   ROLES           AGE     VERSION
master01   Ready    control-plane   6m56s   v1.34.4
master02   Ready    control-plane   3m21s   v1.34.4
worker01   Ready    <none>          63s     v1.34.4
```

## 4) Cluster Information

### Version of installed Kubernetes Client

```bash
kubeadm version -o short
```

### Default YAML manifest used by Kubeadm init

```bash
kubeadm config print init-defaults
```

### Generate Token
```bash
echo "$(kubeadm token create --print-join-command)" > join.sh

kubeadm join 10.100.100.10:6443 \
  --token yw814a.mk47hgqt1yayq26k \
  --discovery-token-ca-cert-hash sha256:7613f7a62eb387ebc300bdd56bcf35782cbf0fea5bc7e622d58bb2b364b08730
```
