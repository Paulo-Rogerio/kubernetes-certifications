# 🚀 Remove Member Etcd

- [1) ETCD StaticPod](#1-etcd-staticpod)
- [1.1) List Member Etcd](#11-list-member-etcd)
- [1.2) Delete Member](#12-add-member)
- [1.3) List Member](#13-list-member)


## 1) ETCD StaticPod

The procedure below will remove a healthy member from the cluster.


## 1.1) List Member Etcd

```bash
cd /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/cluster/staticPod/del-member

sh 02-list-members.sh
+------------------+---------+----------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+----------------------------+----------------------------+------------+
| 4e865953d2bf61f7 | started | master03 | https://10.100.100.13:2380 | https://10.100.100.13:2379 |      false |
| 6f9a16d488597713 | started | master01 | https://10.100.100.11:2380 | https://10.100.100.11:2379 |      false |
| 8cd2a87e18f78509 | started | master02 | https://10.100.100.12:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+----------------------------+----------------------------+------------+
```

## 1.2) Delete Member

To delete a member, you must inform the **Id**. Ex ```etcdctl member remove xxxxxxxx``` . At the time I am removing **member01**.

```bash
sh 03-remove-member.sh  6f9a16d488597713
Member 6f9a16d488597713 removed from cluster 6f56a2558b3ad1a1
```

## 1.3) List Member

```bash
cat > /root/etcdctl.env <<EOF
export ETCDCTL_ENDPOINTS=https://master02:2379,https://master03:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
EOF
source /root/etcdctl.env
etcdctl member list --write-out=table

+------------------+---------+----------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+----------------------------+----------------------------+------------+
| 4e865953d2bf61f7 | started | master03 | https://10.100.100.13:2380 | https://10.100.100.13:2379 |      false |
| 8cd2a87e18f78509 | started | master02 | https://10.100.100.12:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+----------------------------+----------------------------+------------+
```
