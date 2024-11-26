#!/bin/bash

# Instal sshpass jika belum tersedia
echo "Memastikan sshpass terpasang..."
apt update && apt install -y sshpass

# Variabel konfigurasi
MIKROTIK_IP="192.168.31.254"   # IP untuk MikroTik
USERNAME="admin"              # Username MikroTik
PASSWORD="password"           # Password MikroTik

# Skrip konfigurasi MikroTik
echo "Mengirim konfigurasi ke MikroTik..."
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$MIKROTIK_IP << EOF
/interface vlan
add interface=ether2 name=vlan10 vlan-id=10

/ip address
add address=192.168.31.254/24 interface=vlan10

/ip dhcp-client
add interface=ether1 disabled=no

/ip route
add dst-address=0.0.0.0/0 gateway=192.168.31.1

/system reboot
EOF

echo "Konfigurasi MikroTik selesai! MikroTik akan reboot untuk menerapkan konfigurasi."
