#!/usr/bin/env bash

mkdir -p /root/vip

cat >/root/vip/vip.sh <<EOF
#!/usr/bin/env bash

VIP=\$(ip -4 addr show enp1s0 | awk '/inet /{print \$2}' | cut -d/ -f1 | egrep -o 10.100.100.10)

[[ -z \${VIP} ]] && ip a add 10.100.100.10/24 dev enp1s0
EOF

chmod +x /root/vip/vip.sh

cat >> /etc/crontab <<EOF
@reboot root /root/vip/vip.sh
EOF

bash /root/vip/vip.sh
