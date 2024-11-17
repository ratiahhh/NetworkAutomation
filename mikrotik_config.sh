#!/bin/bash

# Variabel Konfigurasi
MIKROTIK_IP="192.168.31.1"      # IP MikroTik
USER_MIKROTIK="admin"           # Username SSH untuk MikroTik
PASSWORD_MIKROTIK="password"    # Password untuk MikroTik (kosongkan jika tidak ada password)
VLAN_ID=10                      # VLAN ID yang ingin dibuat
VLAN_NAME="vlan10"              # Nama VLAN
IP_ADDR="192.168.31.1/24"       # IP untuk VLAN di MikroTik
GATEWAY_IP="192.168.31.1"       # Gateway VLAN
INTERFACE="ether1"              # Interface MikroTik untuk VLAN

# Warna untuk Tampilan
RED='\033[31m'
GREEN='\033[32m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk Menampilkan Status
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
if [ -z "$PASSWORD_MIKROTIK" ]; then
  ssh -o StrictHostKeyChecking=no $USER_MIKROTIK@$MIKROTIK_IP <<EOF
interface vlan add name=$VLAN_NAME vlan-id=$VLAN_ID interface=$INTERFACE
ip address add address=$IP_ADDR interface=$VLAN_NAME
ip route add dst-address=192.168.31.0/24 gateway=$GATEWAY_IP
EOF
else
  sshpass -p "$PASSWORD_MIKROTIK" ssh -o StrictHostKeyChecking=no $USER_MIKROTIK@$MIKROTIK_IP <<EOF
interface vlan add name=$VLAN_NAME vlan-id=$VLAN_ID interface=$INTERFACE
ip address add address=$IP_ADDR interface=$VLAN_NAME
ip route add dst-address=192.168.31.0/24 gateway=$GATEWAY_IP
EOF
fi

# Periksa Status Konfigurasi
print_status
