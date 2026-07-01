#!/usr/bin/env bash

cd $(dirname $0)

function output(){
  echo $(date +%Y-%m-%d-%H:%M:%S) - $@
}

function check_pod_running(){
    deployment=$1
    namespace=$2
    todo=true

    [[ -z ${deployment} || -z ${namespace} ]] && echo "Namespace e Deployment não informados" && exit 1

    while ${todo};
    do
      kubectl rollout status deployment/${deployment} -n ${namespace} &> /dev/null
      [[ $? == 0 ]] && export todo=false
      echo "Waiting Pod Health..."
      sleep 10
    done
    echo "Pods Running"
}

echo "***********************************************************************"
echo "* Install Metallb                                                     *"
echo "***********************************************************************"
echo
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb \
  --namespace metallb-system \
  --create-namespace

# Check
check_pod_running metallb-controller metallb-system

export cidr=$(ip -4 addr show enp1s0 | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
output "CIDR...............: ${cidr}"

export cidr_short=$(cut -d '.' -f1-3 <<< ${cidr})
output "CIDR short.........: ${cidr_short}"

cat > metallb.yaml <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: private-subnet-pool
  namespace: metallb-system
spec:
  addresses:
  - ${cidr_short}.240-${cidr_short}.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: private-subnet-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - private-subnet-pool
EOF

kubectl apply -f metallb.yaml

rm -f metallb.yaml
