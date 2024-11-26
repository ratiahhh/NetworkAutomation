#!/bin/bash

# IP PNET dan VLAN konfigurasi
PNET_IP="192.168.157.129"
PNET_MASK="255.255.255.0"
VLAN_ID=10
VLAN_IP="192.168.31.2"
VLAN_MASK="255.255.255.0"

echo "Mengonfigurasi Cisco Switch..."

cat <<EOT > cisco_config.txt
enable
configure terminal
!
! Konfigurasi IP PNET pada VLAN 1 (Default VLAN)
interface vlan 1
ip address $PNET_IP $PNET_MASK
no shutdown
exit
!
! Konfigurasi VLAN 10
vlan $VLAN_ID
name VLAN_10
exit
!
! Tetapkan port ke VLAN 10
interface e0/1
switchport mode access
switchport access vlan $VLAN_ID
no shutdown
exit
!
! IP Address untuk VLAN 10
interface vlan $VLAN_ID
ip address $VLAN_IP $VLAN_MASK
no shutdown
exit
!
end
write memory
exit
EOT

echo "Konfigurasi Cisco selesai. Periksa koneksi PNET dan VLAN."
