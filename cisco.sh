#!/bin/bash

# Variabel untuk konfigurasi Cisco Switch
SWITCH_IP="192.168.31.4"       # Ganti dengan IP Switch Cisco
USER_SWITCH=""            # Ganti dengan username switch
PASSWORD_SWITCH=""     # Ganti dengan password switch
VLAN_ID=10                     # ID VLAN yang akan dibuat
VLAN_NAME="VLAN10"             # Nama VLAN
INTERFACE="e1"                 # Interface yang akan dikonfigurasi

# Kirim perintah ke Cisco Switch menggunakan sshpass dan SSH
sshpass -p "$PASSWORD_SWITCH" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $USER_SWITCH@$SWITCH_IP << EOF
enable
configure terminal
vlan $VLAN_ID
name $VLAN_NAME
exit
interface $INTERFACE
switchport mode access
switchport access vlan $VLAN_ID
exit
end
write memory
EOF

# Cek apakah konfigurasi berhasil
if [ $? -eq 0 ]; then
  echo "✔ Cisco Switch berhasil dikonfigurasi pada interface $INTERFACE."
else
  echo "✘ Gagal mengonfigurasi Cisco Switch. Periksa koneksi SSH atau konfigurasi VLAN."
  exit 1
fi
