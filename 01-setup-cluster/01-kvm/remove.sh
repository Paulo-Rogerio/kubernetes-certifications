#!/usr/bin/bash

cd $(dirname $0)
sudo virsh destroy control
sudo virsh undefine control --remove-all-storage
sudo virsh destroy worker
sudo virsh undefine worker --remove-all-storage
sudo virsh net-destroy --network cka-net
sudo virsh net-undefine --network cka-net
