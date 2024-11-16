#!/bin/bash

# Variabel Konfigurasi
MIKROTIK_IP="192.168.31.1"     # IP MikroTik (diubah sesuai permintaan)
USER_MIKROTIK="admin"           # Username SSH untuk MikroTik
PASSWORD_MIKROTIK="password"    # Password MikroTik (kosongkan jika tidak ada password)
VLAN_ID=10
VLAN_NAME="vlan10"
IP_ADDR="192.168.31.1/24"        # IP untuk VLAN di MikroTik (diubah sesuai permintaan)
GATEWAY_IP="192.168.31.1"        # Gateway untuk VLAN
INTERFACE="ether1"              # Interface yang digunakan di MikroTik

# Warna untuk tampilan
RED='\033[31m'
GREEN='\033[32m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk menampilkan pesan sukses atau gagal
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Konfigurasi MikroTik berhasil!${RESET}"
  else
    echo -e "${RED}✘ Gagal mengonfigurasi MikroTik!${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}Memulai konfigurasi MikroTik...${RESET}"

# Login ke MikroTik dan lakukan konfigurasi VLAN
echo -e "${CYAN}Membuat VLAN $VLAN_ID ($VLAN_NAME) di MikroTik...${RESET}"

if [ -z "$PASSWORD_MIKROTIK" ]; then
  # Jika MikroTik tidak memiliki password
  ssh -o StrictHostKeyChecking=no $USER_MIKROTIK@$MIKROTIK_IP <<EOF
interface vlan add name=$VLAN_NAME vlan-id=$VLAN_ID interface=$INTERFACE
ip address add address=$IP_ADDR interface=$VLAN_NAME
ip route add dst-address=192.168.31.0/24 gateway=$GATEWAY_IP
EOF
else
  # Jika MikroTik memiliki password
  sshpass -p "$PASSWORD_MIKROTIK" ssh -o StrictHostKeyChecking=no $USER_MIKROTIK@$MIKROTIK_IP <<EOF
interface vlan add name=$VLAN_NAME vlan-id=$VLAN_ID interface=$INTERFACE
ip address add address=$IP_ADDR interface=$VLAN_NAME
ip route add dst-address=192.168.31.0/24 gateway=$GATEWAY_IP
EOF
fi

# Cek status konfigurasi
print_status
