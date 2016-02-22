#!/bin/sh

############### CONFIG
# e.g. 199,203,205-209
# do not include vlan 1
ALL_VLANS='199-299'

# copy user line from a backup
PASSWORD='user name freifunk privilege admin secret 5 passworstring'
DEVICE='TL-SG3424P'
HOSTNAME='albcore-poe-switch'
############### CONFIG

create_port_with_vlan() {
	local portid=$1
	local vlans=$2
	local pvid=$3
cat >> new_config.cfg <<EOF
interface gigabitEthernet 1/0/$portid
  switchport mode trunk
  switchport trunk allowed vlan $vlans
  switchport pvid $pvid
  no switchport trunk allowed vlan 1
#
EOF
}

cat > new_config.cfg <<EOF
!$DEVICE
#
vlan $ALL_VLANS
#
#
#
#
hostname "albcore-poe-switch"
location "alboinkontor"
contact-info "lynxis"
#
mac address-table aging-time 300
#
logging buffer 6
no logging file flash
#
#
system-time ntp UTC+08:00 133.100.9.2 139.78.100.163 12
#
#
user name freifunk privilege admin secret 5 \$1\$J=H>H=D8N>L4@0N1K:F=G>@1A:F6G/C0|}|.}
#
#
#
#
#
#
#
#
#
#
#
EOF

# port 1 => vlan 199+201
# port 2 => vlan 199+202
# port 9 => ...
for port in $(seq 1 16); do
	create_port_with_vlan $port "199,$((200 + port))" 199
done

for port in $(seq 17 24) ; do
	create_port_with_vlan $port $ALL_VLANS 199
done

cat >> new_config.cfg <<EOF
ip management-vlan 199
interface vlan 199
ip address 10.230.132.94 255.255.255.224
#
interface vlan 199
no ipv6 enable 
#
end
EOF

# it requires unix endings
unix2dos new_config.cfg
