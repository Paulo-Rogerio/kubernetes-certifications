#!/usr/bin/env bash

echo -n \
"
Antes de executar o script que inicia o etcd como novo membro, deve-se informar ao cluster existente que
um novo membro deseja-se se tornar membro do cluster.

################################################################

bash /root/kubernetes-certifications/CKA/02-etcd/etcd-manager/data/08-new-member.sh

################################################################

Iniciando Cluster...

bash 08-start.sh

"
