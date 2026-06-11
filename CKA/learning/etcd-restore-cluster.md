# 🚀 Remove Member Etcd

- [1) ETCD StaticPod](#1-etcd-staticpod)
- [1.1) Check Status Backup Etcd](#11-check-status-backup-etcd)
- [1.2) Cleanup Etcd](#12-cleanup-etcd)
- [1.3) Restore Backup Etcd](#13-restore-backup-etcd)
- [1.4) Replace Manifests Yaml Etcd](#14-replace-manifests-yaml-etcd)
- [1.5) Check Restore](#15-check-restore)


## 1) ETCD StaticPod

The procedure below will remove all data for all members. This will leave the cluster unusable.

## 1.1) Check Status Backup Etcd

Check the backup status. As the backup was performed on node **master03**, this script identifies that the backup is not present on the host and copies it to the member in question.

#### ***NOTES.: This script must be executed on each node***

```bash
cd /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/cluster/staticPod/restore

sh 01-status-backup.sh

+----------+----------+------------+------------+---------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE | VERSION |
+----------+----------+------------+------------+---------+
| b54064ca |       13 |          8 |      20 kB |   3.6.0 |
+----------+----------+------------+------------+---------+
```

## 1.2) Cleanup Etcd

#### ***NOTE.: THE PROCEDURES BELOW CAN BE DONE ON ANY OF THE MEMBERS. ALL NODES COMMUNICATE BY KEY.***

The kubelet uploads **etcd** as a static pod, the script stops the **kubelet**service and removes the data persisted in **/var/lib/etcd**

The script runs this on all cluster members: **(master01, master02 and master03)**

```bash
sh 02-cleanup.sh

○ kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
             /etc/systemd/system/kubelet.service.d
             └─20-etcd-service-manager.conf, kubelet.conf
     Active: inactive (dead) since Tue 2026-02-17 15:16:10 -03; 10ms ago
       Docs: https://kubernetes.io/docs/
    Process: 15776 ExecStart=/usr/bin/kubelet --config=/etc/systemd/system/kubelet.service.d/kubelet.conf (code=exited, status=0/SUCCESS)
   Main PID: 15776 (code=exited, status=0/SUCCESS)
        CPU: 1min 40.132s
```


## 1.3) Restore Backup Etcd

The restore process must be executed **MEMBER**by **MEMBER**, so it will be necessary to connect to each member and run the script **03-rescue-backup.sh**

I can start the restore process on any of the members, since **ALL**are already without the **ETCD**.

#### Restore Individually on Each Member


#### ***NOTES.: This script must be executed on each node***

```bash
sh 03-rescue-backup.sh

2026-02-17T15:22:28-03:00	info	snapshot/v3_snapshot.go:305	restoring snapshot	{"path": "/backup/etcd.db", "wal-dir": "/var/lib/etcd/member/wal", "data-dir": "/var/lib/etcd", "snap-dir": "/var/lib/etcd/member/snap", "initial-memory-map-size": 10737418240}
2026-02-17T15:22:28-03:00	info	bbolt	backend/backend.go:203	Opening db file (/var/lib/etcd/member/snap/db) with mode -rw------- and with options: {Timeout: 0s, NoGrowSync: false, NoFreelistSync: true, PreLoadFreelist: false, FreelistType: , ReadOnly: false, MmapFlags: 8000, InitialMmapSize: 10737418240, PageSize: 0, NoSync: false, OpenFile: 0x0, Mlock: false, Logger: 0xc0000642d0}
2026-02-17T15:22:28-03:00	info	bbolt	bbolt@v1.4.3/db.go:321	Opening bbolt db (/var/lib/etcd/member/snap/db) successfully
2026-02-17T15:22:28-03:00	info	schema/membership.go:138	Trimming membership information from the backend...
2026-02-17T15:22:28-03:00	info	bbolt	backend/backend.go:203	Opening db file (/var/lib/etcd/member/snap/db) with mode -rw------- and with options: {Timeout: 0s, NoGrowSync: false, NoFreelistSync: true, PreLoadFreelist: false, FreelistType: , ReadOnly: false, MmapFlags: 8000, InitialMmapSize: 10737418240, PageSize: 0, NoSync: false, OpenFile: 0x0, Mlock: false, Logger: 0xc00051e018}
2026-02-17T15:22:28-03:00	info	bbolt	bbolt@v1.4.3/db.go:321	Opening bbolt db (/var/lib/etcd/member/snap/db) successfully
2026-02-17T15:22:28-03:00	info	membership/cluster.go:424	added member	{"cluster-id": "30dde90c3b4a982b", "local-member-id": "0", "added-peer-id": "6f9a16d488597713", "added-peer-peer-urls": ["https://10.100.100.11:2380"], "added-peer-is-learner": false}
2026-02-17T15:22:28-03:00	info	membership/cluster.go:424	added member	{"cluster-id": "30dde90c3b4a982b", "local-member-id": "0", "added-peer-id": "7371c966708fc406", "added-peer-peer-urls": ["https://10.100.100.13:2380"], "added-peer-is-learner": false}
2026-02-17T15:22:28-03:00	info	membership/cluster.go:424	added member	{"cluster-id": "30dde90c3b4a982b", "local-member-id": "0", "added-peer-id": "8cd2a87e18f78509", "added-peer-peer-urls": ["https://10.100.100.12:2380"], "added-peer-is-learner": false}
2026-02-17T15:22:28-03:00	info	bbolt	backend/backend.go:203	Opening db file (/var/lib/etcd/member/snap/db) with mode -rw------- and with options: {Timeout: 0s, NoGrowSync: false, NoFreelistSync: true, PreLoadFreelist: false, FreelistType: , ReadOnly: false, MmapFlags: 8000, InitialMmapSize: 10737418240, PageSize: 0, NoSync: false, OpenFile: 0x0, Mlock: false, Logger: 0xc0000647c8}
2026-02-17T15:22:28-03:00	info	bbolt	bbolt@v1.4.3/db.go:321	Opening bbolt db (/var/lib/etcd/member/snap/db) successfully
2026-02-17T15:22:28-03:00	info	snapshot/v3_snapshot.go:333	restored snapshot	{"path": "/backup/etcd.db", "wal-dir": "/var/lib/etcd/member/wal", "data-dir": "/var/lib/etcd", "snap-dir": "/var/lib/etcd/member/snap", "initial-memory-map-size": 10737418240}

```

## 1.4) Replace Manifests Yaml Etcd

Now that the restore has happened, we need to adjust the **YAML**of all members, defining that everyone would start the cluster with **state NEW**.

The script also starts the kubelet.

#### ***NOTES.: This script must be executed on each node***

```bash
sh 04-replace-manifests.sh

Start Kubelet....
```

```bash
crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE
ac1b857294cb0       a3e246e9556e9       35 seconds ago      Running             etcd                0                   44fbcf6b6bd97       etcd-master03       kube-system
```

## 1.5) Check Restore

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

+------------------+---------+----------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+----------------------------+----------------------------+------------+
| 6f9a16d488597713 | started | master01 | https://10.100.100.11:2380 | https://10.100.100.11:2379 |      false |
| 7371c966708fc406 | started | master03 | https://10.100.100.13:2380 | https://10.100.100.13:2379 |      false |
| 8cd2a87e18f78509 | started | master02 | https://10.100.100.12:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+----------------------------+----------------------------+------------+


+-----------------------+--------+-------------+-------+
|       ENDPOINT        | HEALTH |    TOOK     | ERROR |
+-----------------------+--------+-------------+-------+
| https://master03:2379 |   true |  9.071282ms |       |
| https://master01:2379 |   true | 16.339434ms |       |
| https://master02:2379 |   true | 17.009107ms |       |
+-----------------------+--------+-------------+-------+


+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
|       ENDPOINT        |        ID        | VERSION | STORAGE VERSION | DB SIZE | IN USE | PERCENTAGE NOT IN USE | QUOTA | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS | DOWNGRADE TARGET VERSION | DOWNGRADE ENABLED |
+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
| https://master01:2379 | 6f9a16d488597713 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |      true |      false |         2 |         10 |                 10 |        |                          |             false |
| https://master02:2379 | 8cd2a87e18f78509 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         10 |                 10 |        |                          |             false |
| https://master03:2379 | 7371c966708fc406 |   3.6.5 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         10 |                 10 |        |                          |             false |
+-----------------------+------------------+---------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
```
