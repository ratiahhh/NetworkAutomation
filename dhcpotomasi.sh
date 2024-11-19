#!/bin/bash

# Variabel Konfigurasi
VLAN_INTERFACE="eth1.10"        # VLAN Interface
VLAN_ID=10                      # VLAN ID
IP_ADDR="192.168.31.1/24"       # IP Address untuk VLAN
DHCP_CONF="/etc/dhcp/dhcpd.conf" # File konfigurasi DHCP
DHCP_RANGE_START="192.168.31.10" # Rentang DHCP
DHCP_RANGE_END="192.168.31.100"
DNS_SERVERS="8.8.8.8, 8.8.4.4"   # DNS Server untuk DHCP
INTERNET_INTERFACE="eth0"        # Interface yang terhubung ke internet

# Warna untuk tampilan
GREEN='\033[32m'
RED='\033[31m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk menampilkan status
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Sukses${RESET}"
  else
    echo -e "${RED}✘ Gagal${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}Mengonfigurasi Ubuntu Server untuk VLAN, DHCP, dan routing...${RESET}"

# 1. Mengaktifkan IP Forwarding
echo -e "${CYAN}Mengaktifkan IP Forwarding...${RESET}"
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
print_status

# 2. Menyiapkan Interface VLAN
echo -e "${CYAN}Membuat interface VLAN ${VLAN_INTERFACE}...${RESET}"
sudo ip link add link eth1 name $VLAN_INTERFACE type vlan id $VLAN_ID
sudo ip addr add $IP_ADDR dev $VLAN_INTERFACE
sudo ip link set up dev $VLAN_INTERFACE
print_status

# 3. Konfigurasi Netplan
echo -e "${CYAN}Mengonfigurasi Netplan untuk VLAN dan Internet...${RESET}"
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
      id: $VLAN_ID
      link: eth1
      addresses:
        - $IP_ADDR
EOF

sudo netplan apply
print_status

# 4. Konfigurasi DHCP Server
echo -e "${CYAN}Mengonfigurasi DHCP Server...${RESET}"
sudo apt update
sudo apt install -y isc-dhcp-server

cat <<EOL | sudo tee $DHCP_CONF
subnet 192.168.31.0 netmask 255.255.255.0 {
    range $DHCP_RANGE_START $DHCP_RANGE_END;
    option routers 192.168.31.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers $DNS_SERVERS;
}
EOL

sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server
print_status

# 5. Konfigurasi IPTables untuk NAT
echo -e "${CYAN}Mengonfigurasi IPTables untuk NAT...${RESET}"
sudo iptables -t nat -A POSTROUTING -o $INTERNET_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $VLAN_INTERFACE -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
print_status

# 6. Verifikasi
echo -e "${CYAN}Memeriksa konfigurasi...${RESET}"
echo -e "${CYAN}1. IP Forwarding:${RESET}"
cat /proc/sys/net/ipv4/ip_forward
echo -e "${CYAN}2. Interface VLAN:${RESET}"
ip -d link show $VLAN_INTERFACE
echo -e "${CYAN}3. Status DHCP Server:${RESET}"
sudo systemctl status isc-dhcp-server
echo -e "${CYAN}4. Konfigurasi IPTables:${RESET}"
sudo iptables -L -t nat

echo -e "${GREEN}Konfigurasi selesai! DHCP dan NAT berhasil diterapkan.${RESET}"
echo -e "${CYAN}Pastikan perangkat klien mendapatkan IP dari rentang DHCP (192.168.31.10 - 192.168.31.100).${RESET}"
