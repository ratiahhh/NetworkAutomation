#!/bin/bash

# Variabel Konfigurasi
SWITCH_IP="192.168.31.35"       
USER_SWITCH="root"             
PASSWORD_SWITCH="root"         
VLAN_ID=10
VLAN_NAME="VLAN10"
INTERFACE="e0/1"               
# Warna untuk tampilan
RED='\033[31m'
GREEN='\033[32m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk menampilkan pesan sukses atau gagal
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Konfigurasi Cisco Switch berhasil!${RESET}"
  else
    echo -e "${RED}✘ Gagal mengonfigurasi Cisco Switch!${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}Memulai konfigurasi Cisco Switch...${RESET}"

# Login ke Cisco Switch dan lakukan konfigurasi VLAN
echo -e "${CYAN}Membuat VLAN $VLAN_ID ($VLAN_NAME) di Cisco Switch...${RESET}"
sshpass -p "$PASSWORD_SWITCH" ssh -o StrictHostKeyChecking=no $USER_SWITCH@$SWITCH_IP <<EOF
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

# Cek status konfigurasi
print_status
