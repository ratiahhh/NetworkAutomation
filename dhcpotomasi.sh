#!/bin/bash

# Variabel Konfigurasi
VLAN_INTERFACE="eth1.10"
VLAN_ID=10
IP_ADDR="192.168.31.1/24"      # IP address untuk interface VLAN di Ubuntu
DHCP_CONF="/etc/dhcp/dhcpd.conf"
SWITCH_IP="192.168.31.35"       # IP Cisco Switch yang akan dikonfigurasi
MIKROTIK_IP="192.168.200.1"     # IP MikroTik yang baru
USER_SWITCH="root"              # Username SSH untuk Cisco Switch
USER_MIKROTIK="admin"           # Username SSH default MikroTik
PASSWORD_SWITCH="root"          # Password untuk Cisco Switch
PASSWORD_MIKROTIK=""            # Kosongkan jika MikroTik tidak punya password

set -e

# Warna untuk tampilan
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk menampilkan pesan sukses atau gagal
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Sukses${RESET}"
  else
    echo -e "${RED}✘ Gagal${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}Skrip Otomasi Ubuntu dimulai. Siapkan sistem Anda untuk otomatisasi konfigurasi!${RESET}"

# 1. Menambahkan Repositori Kartolo
echo -e "${BLUE}Menambahkan repositori Kartolo ke sumber apt...${RESET}"
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

sudo apt update
sudo apt install sshpass -y
sudo apt install -y isc-dhcp-server iptables iptables-persistent

# 2. Menyiapkan dan Mengaktifkan Interface Ethernet
echo -e "${YELLOW}Memeriksa dan mengaktifkan interface ethernet...${RESET}"
ip link set eth0 up
ip link set eth1 up
print_status

# 3. Konfigurasi VLAN di Ubuntu Server
echo -e "${YELLOW}Membuat VLAN di Ubuntu Server...${RESET}"
ip link add link eth1 name $VLAN_INTERFACE type vlan id $VLAN_ID
ip addr add $IP_ADDR dev $VLAN_INTERFACE
ip link set up dev $VLAN_INTERFACE
print_status

# 4. Konfigurasi DHCP Server
echo -e "${CYAN}Mengonfigurasi DHCP Server...${RESET}"
cat <<EOL | sudo tee $DHCP_CONF
# Konfigurasi subnet untuk VLAN 10
subnet 192.168.31.0 netmask 255.255.255.0 {
    range 192.168.31.10 192.168.6.100;
    option routers 192.168.31.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option domain-name "example.local";
}
EOL
print_status

# 5. Menyiapkan Konfigurasi Netplan
echo -e "${CYAN}Menyusun konfigurasi Netplan...${RESET}"
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
     dhcp4: true
    eth1:
      dhcp4: no
  vlans:
     eth1.10:
       id: 10
       link: eth1
       addresses: [192.168.31.1/24]
EOF
print_status

# 6. Menerapkan Konfigurasi Netplan
echo -e "${CYAN}Menerapkan konfigurasi Netplan...${RESET}"
sudo netplan apply
print_status

# 7. Restart DHCP server untuk menerapkan konfigurasi baru
echo -e "${CYAN}Merestart DHCP server...${RESET}"
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
print_status

# 8. Konfigurasi Routing di Ubuntu Server
echo -e "${YELLOW}Menambahkan routing ke jaringan MikroTik...${RESET}"
ip route add 192.168.200.0/24 via $MIKROTIK_IP
print_status

echo -e "${GREEN}Skrip selesai! Konfigurasi berhasil diterapkan.${RESET}"

