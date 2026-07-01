# 🚀 Learn Etcd

- [1) Vms Requisitos](#1-vms-requisitos)
- [2) Vms Startup](#2-vms-startup)
- [3) ETCD StaticPod](#3-etcd-staticpod)


## 1) Vms Requisitos

To run this lab it is necessary to have **KVM**installed on the host, as it will emulate all the necessary vms.

#### Imagens Cloud

It is necessary to download the image in **qcow2**format, which is already adapted to run with cloud-init. [Official Download](https://cloud-images.ubuntu.com/).

#### Image Directory

This script assumes that the images must be located in **/var/lib/libvirt/images/**.

#### Chave SSH

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
```

#### Password Default todas as Vms

All VMs have a default password already defined in cloud-init **123456**.

## 2) Vms Startup

[Clone the Repository](https://github.com/Paulo-Rogerio/kubernetes-certifications.git), and navigate to the **01-kvm**directory. In this directory, you will find a **hosts.txt**file, which will define the number of hosts your laboratory will have.

```bash
#=================================================================
# Learning K8S
#=================================================================
# master01    2048  3  10.100.100.11  noble-server-cloudimg-amd64.img
# worker01    2048  3  10.100.100.20  noble-server-cloudimg-amd64.img

#=================================================================
# Learning ETCD
#=================================================================
master01  2048  3  10.100.100.11  noble-server-cloudimg-amd64.img
master02  2048  3  10.100.100.12  noble-server-cloudimg-amd64.img

#=================================================================
# Learning K8S - MultiMaster
#=================================================================
# master01    2048  3  10.100.100.11  noble-server-cloudimg-amd64.img
# master02    2048  3  10.100.100.12  noble-server-cloudimg-amd64.img
# worker01    2048  3  10.100.100.20  noble-server-cloudimg-amd64.img
```

The installer already guarantees that this network will be created, so **DO NOT**change the range **10.100.100.**. This network is created in **NAT**mode, to avoid any type of conflict.

#### Starting VMS

This utility already creates all the necessary requirements.

```bash
sh deploy.sh
```

Connect to the newly created VM.

```bash
ssh root@master01
```

#### Removing VMS

Remove the Vms after the lab is finished.

```bash
sh remove.sh
```

## 3) ETCD StaticPod


After deploying the Vms, connect to (**master01 and master02**). For this lab we will deploy the internal **etcd**, maintained and managed by **kubernetes**via **StaticPod**.


Connect to master01...

```bash
ssh root@master01
cd kubernetes-certifications/CKA/02-etcd/etcd-staticPod/

bash deploy.sh

crictl ps -a | grep etcd
crictl logs 992e3500eddf6
systemctl status kubelet

+------------------+---------+----------+-----------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |      PEER ADDRS       |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+-----------------------+----------------------------+------------+
| 564yru980out75ut | started | master01 | https://master01:2380 | https://10.100.100.11:2379 |      false |
| 7rurjt778iuo98tg | started | master02 | https://master02:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+-----------------------+----------------------------+------------+
```

#### NOTE: The same script serves both implementations

Connect to master02 and perform a similar procedure

```bash
ssh root@master02
cd kubernetes-certifications/CKA/02-etcd/etcd-staticPod/

bash deploy.sh

crictl ps -a | grep etcd
crictl logs 992e3500eddf6
systemctl status kubelet

+------------------+---------+----------+-----------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |      PEER ADDRS       |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+-----------------------+----------------------------+------------+
| 564yru980out75ut | started | master01 | https://master01:2380 | https://10.100.100.11:2379 |      false |
| 7rurjt778iuo98tg | started | master02 | https://master02:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+-----------------------+----------------------------+------------+
```
