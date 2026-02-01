#!/usr/bin/env bash

cd $(dirname $0)

mkdir -p /etc/kubernetes/pki/etcd

# Gerando CA
echo "======================================================"
echo " Gerando CA                                           "
echo "======================================================"

cat > certs/ca-config.json <<EOF
{
    "signing": {
        "default": {
            "expiry": "8760h"
        },
        "profiles": {
            "etcd": {
                "expiry": "8760h",
                "usages": ["signing","key encipherment","server auth","client auth"]
            }
        }
    }
}
EOF

cat > certs/ca-csr.json <<EOF
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "BR",
      "L": "Brasil",
      "O": "Kubernetes",
      "OU": "Etcd",
      "ST": "Goiania"
    }
  ]
}
EOF

cd certs
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
cd -

# Gerando Certiciados ETCD
echo "======================================================"
echo " Gerando Certificados ETCD                            "
echo "======================================================"

cat > certs/etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "localhost",
    "127.0.0.1",
    "master00",
    "master01",
    "master02"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "BR",
      "L": "Brasil",
      "O": "Kubernetes",
      "OU": "Etcd",
      "ST": "Goiania"
    }
  ]
}
EOF

cd certs
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson -bare etcd
rm -f ca-config.json ca-csr.json etcd-csr.json

cp ca.pem /etc/kubernetes/pki/etcd/ca.crt
cp etcd.pem /etc/kubernetes/pki/etcd/etcd.crt
cp etcd-key.pem /etc/kubernetes/pki/etcd/etcd.key

cd -
