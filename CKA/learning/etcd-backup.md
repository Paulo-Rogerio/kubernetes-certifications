# 🚀 Backup Cluster Etcd

- [1) ETCD StaticPod](#1-etcd-staticpod)
- [1.1) List Member Etcd](#11-list-member-etcd)
- [1.2) Backup Etcd](#12-backup-etcd)

## 1) ETCD StaticPod

The procedure below can be performed on any member of the cluster. The **backup**will be stored on the server where the backup will take place.


## 1.1) List Member Etcd

```bash
cd /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/cluster/staticPod/backup

sh 02-list-members.sh
+------------------+---------+----------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |   NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+----------+----------------------------+----------------------------+------------+
| 4e865953d2bf61f7 | started | master03 | https://10.100.100.13:2380 | https://10.100.100.13:2379 |      false |
| 6f9a16d488597713 | started | master01 | https://10.100.100.11:2380 | https://10.100.100.11:2379 |      false |
| 8cd2a87e18f78509 | started | master02 | https://10.100.100.12:2380 | https://10.100.100.12:2379 |      false |
+------------------+---------+----------+----------------------------+----------------------------+------------+
```

## 1.2) Backup Cluster

The backup will be saved in **/backup/etcd.db**.

```bash
sh 03-backup.sh

{"level":"info","ts":"2026-02-17T14:51:16.828882-0300","caller":"snapshot/v3_snapshot.go:83","msg":"created temporary db file","path":"/backup/etcd.db.part"}
{"level":"info","ts":"2026-02-17T14:51:16.837089-0300","logger":"client","caller":"v3@v3.6.8/maintenance.go:236","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2026-02-17T14:51:16.841000-0300","caller":"snapshot/v3_snapshot.go:96","msg":"fetching snapshot","endpoint":"https://master03:2379"}
{"level":"info","ts":"2026-02-17T14:51:16.841375-0300","logger":"client","caller":"v3@v3.6.8/maintenance.go:302","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2026-02-17T14:51:16.843967-0300","caller":"snapshot/v3_snapshot.go:111","msg":"fetched snapshot","endpoint":"https://master03:2379","size":"20 kB","took":"14.917492ms","etcd-version":"3.6.0"}
{"level":"info","ts":"2026-02-17T14:51:16.844185-0300","caller":"snapshot/v3_snapshot.go:121","msg":"saved","path":"/backup/etcd.db"}

Snapshot saved at /backup/etcd.db
Server version 3.6.0
```

## 1.3) Check Backup

```bash
sh 04-check-backup.sh
+----------+----------+------------+------------+---------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE | VERSION |
+----------+----------+------------+------------+---------+
| b54064ca |       13 |          8 |      20 kB |   3.6.0 |
+----------+----------+------------+------------+---------+
```
