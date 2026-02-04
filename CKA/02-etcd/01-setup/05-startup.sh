cd $(dirname $0)

NAME=$(hostname -s)
NODE=$(ip -4 addr show enp1s0 | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)

mkdir -p /var/lib/etcd
chmod 700 /var/lib/etcd

cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://etcd.io
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=root
ExecStart=/usr/local/bin/etcd \\
  --name ${NAME} \\
  --data-dir /var/lib/etcd \\
  --initial-advertise-peer-urls https://${NODE}:2380 \\
  --listen-peer-urls https://${NODE}:2380 \\
  --listen-client-urls https://${NODE}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${NODE}:2379 \\
  --initial-cluster-token estudos-etcd \\
  --initial-cluster master01=https://master01:2380,master02=https://master02:2380 \\
  --initial-cluster-state new \\
  --client-cert-auth \\
  --peer-client-cert-auth \\
  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --cert-file=/etc/kubernetes/pki/etcd/etcd.crt \\
  --key-file=/etc/kubernetes/pki/etcd/etcd.key \\
  --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --peer-cert-file=/etc/kubernetes/pki/etcd/etcd.crt \\
  --peer-key-file=/etc/kubernetes/pki/etcd/etcd.key \\
  --auto-compaction-retention=1

Restart=always
RestartSec=5
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

mv etcd.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now etcd.service
