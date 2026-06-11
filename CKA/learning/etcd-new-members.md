# 🚀 Adicionar Member Etcd

- [1) ETCD StaticPod](#1-etcd-staticpod)
- [1.1) Add Member](#11-add-member)
- [1.2) Start New Member](#12-start-new-member)
- [1.3) Check New Member](#13-check-new-member)

## 1) ETCD StaticPod

In this material we will show how to manage the cluster, adding and removing members to the cluster.

## 1.1) Add Member

Connect to **member03**to start the procedure

```bash
ssh root@master03
cd /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/cluster/staticPod/add-Member

bash deploy.sh
```

When the deployment is complete, the following message will be displayed.

#### NOTE: THE SCRIPT MUST BE RUN ON AN ACTIVE MEMBER (master01 or master02)

```bash
Before running the script that starts etcd as a new member, you must inform the existing cluster that
a new member wants to become a member of the cluster.

################################################################

bash /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/data/08-new-member.sh

################################################################
```

The script to be executed is **08-new-member.sh**, it needs to notify the cluster of the existence of a new member.

The script boils down to this...

```bash
cat > /root/etcdctl.env <<EOF
export ETCDCTL_ENDPOINTS=https://master01:2379,https://master02:2379,https://master03:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
EOF

source /root/etcdctl.env
etcdctl member add master03 --peer-urls=https://10.100.100.13:2380
```

At this point in the championship, **NOT** there are any pods in this new cluster.

```bash
crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE
```

When executing the requested script **08-new-member.sh**on one of the members, the following message will be displayed. The new member is expected to take on these duties.

```bash
sh 08-new-member.sh
Member 4e865953d2bf61f7 added to cluster 6f56a2558b3ad1a1

ETCD_NAME="master03"
ETCD_INITIAL_CLUSTER="master03=https://10.100.100.13:2380,master01=https://10.100.100.11:2380,master02=https://10.100.100.12:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.100.100.13:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

If you look at the **04-kubeadmcfg.sh**script, it injects these same settings into the pod constructor.

```yaml
...
...
apiVersion: "kubeadm.k8s.io/v1beta4"
kind: ClusterConfiguration
etcd:
 local:
    serverCertSANs:
    - "10.100.100.13"
    peerCertSANs:
    - "10.100.100.13"
    extraArgs:
    - name: initial-cluster
      value: master01=https://10.100.100.11:2380,master02=https://10.100.100.12:2380,master03=https://10.100.100.13:2380
    - name: initial-cluster-state
      value: existing
    - name: name
      value: master03
    - name: listen-peer-urls
...
...
```

## 1.2) Start New Member

```bash
sh 08-start.sh
I0217 14:16:13.541949   15992 version.go:260] remote version is much newer: v1.35.1; falling back to: stable-1.34
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
```

```bash
crictl ps
CONTAINER           IMAGE               CREATED              STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE
9b267ede77203       a3e246e9556e9       About a minute ago   Running             etcd                0                   cef1123b1bc88       etcd-master03       kube-system
```

## 1.3) Check New Member

```bash
#!/usr/bin/env bash

cat > /root/etcdctl.env <<EOF
export ETCDCTL_ENDPOINTS=https://master01:2379,https://master02:2379,https://master03:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
EOF

source /root/etcdctl.env
etcdctl member list --write-out=table
echo
echo
etcdctl endpoint health --write-out=table
echo
echo
etcdctl endpoint status --write-out=table
```

```bash
+------------------+---------+----------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+----------------------------+----------------------------+------------+
| 4e865953d2bf61f7 | started | master03 | https://10.100.100.13:2380 | https://10.100.100.13:2379 |      false |
| 6f9a16d488597713 | started | master01 | https://10.100.100.11:2380 | https://10.100.100.11:2379 |      false |
| 8cd2a87e18f78509 | started | master02 | https://10.100.100.12:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+----------------------------+----------------------------+------------+


+-----------------------+--------+-------------+-------+
|       ENDPOINT        | HEALTH |    TOOK     | ERROR |
+-----------------------+--------+-------------+-------+
| https://master02:2379 |   true | 10.779414ms |       |
| https://master01:2379 |   true | 13.641353ms |       |
| https://master03:2379 |   true | 10.888636ms |       |
+-----------------------+--------+-------------+-------+


+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
|       ENDPOINT        |        ID        | VERSION | STORAGE VERSION | DB SIZE | IN USE | PERCENTAGE NOT IN USE | QUOTA | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS | DOWNGRADE TARGET VERSION | DOWNGRADE ENABLED |
+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
| https://master01:2379 | 6f9a16d488597713 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |      true |      false |         2 |         27 |                 27 |        |                          |             false |
| https://master02:2379 | 8cd2a87e18f78509 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         27 |                 27 |        |                          |             false |
| https://master03:2379 | 4e865953d2bf61f7 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         27 |                 27 |        |                          |             false |
+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
```
