#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[31mJalankan script ini sebagai root!\033[0m"
  exit 1
fi

# Warna untuk tampilan
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk memastikan interface jaringan aktif
check_network_status() {
  local interface=$1
  status=$(ip link show "$interface" | grep "state UP")
  if [ -z "$status" ]; then
    echo -e "${YELLOW}Interface $interface tidak aktif, mencoba mengaktifkannya...${RESET}"
    ip link set "$interface" up
    sleep 1
  else
    echo -e "${GREEN}Interface $interface sudah aktif.${RESET}"
  fi
}

# Fungsi untuk menampilkan pesan sukses atau gagal
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Sukses${RESET}"
  else
    echo -e "${RED}✘ Gagal${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}==> Memastikan jaringan dalam keadaan UP...${RESET}"
check_network_status eth0
check_network_status eth1

echo -e "${CYAN}==> Update dan install paket yang diperlukan...${RESET}"
DEBIAN_FRONTEND=noninteractive apt update -y &>/dev/null && apt install -y isc-dhcp-server vlan net-tools apache2 php libapache2-mod-php &>/dev/null
print_status

echo -e "${CYAN}==> Membuat konfigurasi Netplan untuk VLAN...${RESET}"
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      dhcp4: false
  vlans:
    vlan10:
      id: 10
      link: eth1
      addresses:
        - 192.168.10.1/24
EOF
print_status

echo -e "${CYAN}==> Menerapkan konfigurasi Netplan...${RESET}"
netplan try &>/dev/null && netplan apply
print_status

echo -e "${CYAN}==> Menyiapkan konfigurasi DHCP server...${RESET}"
cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.10.0 netmask 255.255.255.0 {
  range 192.168.10.100 192.168.10.200;
  option routers 192.168.10.1;
  option broadcast-address 192.168.10.255;
}
EOF
print_status

echo -e "${CYAN}==> Restarting DHCP server...${RESET}"
systemctl restart isc-dhcp-server
if ! systemctl is-active --quiet isc-dhcp-server; then
  echo -e "${RED}✘ Gagal memulai DHCP server. Periksa konfigurasi di /etc/dhcp/dhcpd.conf.${RESET}"
  exit 1
fi
echo -e "${GREEN}✔ DHCP server berhasil dijalankan.${RESET}"

echo -e "${CYAN}==> Menginstal Kartolo Monitoring Dashboard...${RESET}"
cd /var/www/html
if [ ! -d "kartolo" ]; then
  git clone https://github.com/kartolo-framework/kartolo.git kartolo &>/dev/null
  print_status
else
  echo -e "${YELLOW}Kartolo sudah ada di /var/www/html/kartolo. Melewati langkah ini.${RESET}"
fi

echo -e "${CYAN}==> Konfigurasi Apache untuk Kartolo...${RESET}"
cat <<EOF > /etc/apache2/sites-available/kartolo.conf
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/kartolo
    <Directory /var/www/html/kartolo>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite kartolo &>/dev/null
a2enmod rewrite &>/dev/null
systemctl reload apache2
print_status

echo -e "${CYAN}==> Membersihkan cache dan file sementara...${RESET}"
apt autoremove -y &>/dev/null
apt clean &>/dev/null
print_status

echo -e "${GREEN}✔ Semua konfigurasi selesai!${RESET}"
echo -e "${BLUE}Anda dapat mengakses Kartolo Monitoring Dashboard di: http://<IP-server-Anda>${RESET}"
