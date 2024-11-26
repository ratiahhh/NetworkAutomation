#!/bin/bash

# IP PNET dan VLAN konfigurasi
PNET_IP="192.168.157.130/24"
PNET_INTERFACE="ether2"
VLAN_ID=10
VLAN_INTERFACE="vlan10"
VLAN_IP="192.168.31.254/24"

echo "Mengonfigurasi MikroTik..."

cat <<EOT > mikrotik_config.rsc
# Konfigurasi IP PNET pada $PNET_INTERFACE
/ip address add address=$PNET_IP interface=$PNET_INTERFACE
/interface ethernet enable $PNET_INTERFACE

# Buat VLAN 10 pada $PNET_INTERFACE
/interface vlan add name=$VLAN_INTERFACE vlan-id=$VLAN_ID interface=$PNET_INTERFACE
/ip address add address=$VLAN_IP interface=$VLAN_INTERFACE

# Pastikan forwarding aktif
/ip route add gateway=192.168.31.1
EOT

echo "Konfigurasi MikroTik selesai. Pastikan IP PNET terhubung."
