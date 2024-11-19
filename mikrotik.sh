#!/bin/bash

# Variabel untuk konfigurasi MikroTik
MIKROTIK_IP="192.168.157.135"       # Ganti dengan IP MikroTik
USER_MIKROTIK="admin"            # Ganti dengan username MikroTik
PASSWORD_MIKROTIK="123"     # Ganti dengan password MikroTik
VLAN_ID=10                       # ID VLAN
VLAN_NAME="VLAN10"               # Nama VLAN
INTERFACE="eth1"                 # Interface yang akan dikonfigurasi

# Kirim perintah ke MikroTik menggunakan sshpass dan SSH
sshpass -p "$PASSWORD_MIKROTIK" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $USER_MIKROTIK@$MIKROTIK_IP << EOF
/interface vlan
add name=$VLAN_NAME vlan-id=$VLAN_ID interface=$INTERFACE
/ip address
add address=192.168.31.254/24 interface=$VLAN_NAME
EOF

# Cek apakah konfigurasi berhasil
if [ $? -eq 0 ]; then
  echo "✔ MikroTik berhasil dikonfigurasi pada interface $INTERFACE."
else
  echo "✘ Gagal mengonfigurasi MikroTik. Periksa koneksi SSH atau konfigurasi VLAN."
  exit 1
fi
