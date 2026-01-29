#!/usr/bin/env bash

function install()
{
  export name=$1
  export ram=$2
  export vcpu=$3
  export ip=$4
  export image=$5

  network
  userdata

  sudo qemu-img create -b /var/lib/libvirt/images/${image} -f qcow2 -F qcow2 /var/lib/libvirt/images/${name}.qcow2 50G
  sudo virt-install \
    --name ${name} \
    --disk path="/var/lib/libvirt/images/${name}.qcow2",device=disk,bus=scsi \
    --os-variant "ubuntu-stable-latest" \
    --network network=cka-net,model=virtio \
    --virt-type kvm \
    --vcpus "${vcpu}" \
    --memory "${ram}" \
    --console pty,target_type=serial \
    --cloud-init user-data=./user-data.yml,network-config=./network.yml \
    --import \
    --noautoconsole

  rm -f network.yml  
  rm -f user-data.yml
}

function network() 
{
  cat > network.yml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: false
      addresses:
        - ${ip}
      gateway4: 10.100.100.1 
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]        
EOF
}

function userdata()
{
  cat > user-data.yml <<EOF  
#cloud-config

disable_root: 0
ssh_pwauth: 1

chpasswd:
  expire: false
  list: |
    root:123456
    paulo:123456

hostname: ${name}

users:
  - name: root
    plain_text_passwd: 123456
    ssh_authorized_keys:
      - $(cat ~/.ssh/id_ed25519.pub)

  - name: paulo
    plain_text_passwd: 123456
    ssh_authorized_keys:
      - publica-aqui
      - $(cat ~/.ssh/id_ed25519.pub)
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash

write_files:
  - path: /home/paulo/.ssh/id_rsa
    owner: paulo:paulo
    permissions: 0o600
    defer: true
    encoding: base64
    content: |
      $(base64 -w0 < ~/.ssh/id_ed25519)

# do some package management
package_upgrade: none
repo_upgrade: none
EOF
}

#==================================
# Call
#==================================
install "control" 2048  3  "10.100.100.10/24"  "jammy-server-cloudimg-amd64.img"
install "worker"  4096  4  "10.100.100.11/24"  "jammy-server-cloudimg-amd64.img"

