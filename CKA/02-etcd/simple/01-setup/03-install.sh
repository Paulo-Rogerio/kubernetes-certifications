#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt install -y tzdata curl bash openssl jq

export ETCD_VERSION=$(curl -sSL https://api.github.com/repos/etcd-io/etcd/releases/latest | jq -r .tag_name)
export DOWNLOAD_URL="https://github.com/etcd-io/etcd/releases/download"

curl -sSL ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
mkdir -p /tmp/etcd-download
tar -xzvf /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C /tmp/etcd-download --strip-components=1

rm -f /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
mv /tmp/etcd-download/etcd* /usr/local/bin

curl -sSL -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -sSL -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x /usr/local/bin/cfssl
chmod +x /usr/local/bin/cfssljson
