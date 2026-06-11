#!/usr/bin/env bash
source ./01-env.sh

for i in {1..10}
do
  etcdctl get chave${i} -w simple
  echo "---------"
done

echo "################## JQ ####################"

# Everything that starts with the word"chave"
etcdctl get chave --prefix -w json | jq .
