#!/bin/bash

# Membersihkan layar
clear

# ====== ASCII Art ======
echo -e "\033[1;36m" # Warna Cyan
echo "██████╗░░█████╗░████████╗██╗░█████╗░██╗░░██╗"
echo "██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗██║░░██║"
echo "██████╔╝███████║░░░██║░░░██║███████║███████║"
echo "██╔══██╗██╔══██║░░░██║░░░██║██╔══██║██╔══██║"
echo "██║░░██║██║░░██║░░░██║░░░██║██║░░██║██║░░██║"
echo "╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝"
echo -e "\033[0m"

# Mengecek koneksi internet
echo "Mengecek koneksi internet..."
ping -c 3 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mTidak ada koneksi internet. Silakan periksa jaringan Anda.\033[0m"
    exit 1
fi
echo -e "\033[1;32mKoneksi internet terdeteksi. Melanjutkan...\033[0m"

# Menambahkan Repository Debian 10 jika belum ada
REPO="http://kartolo.sby.datautama.net.id/debian/"
if ! grep -q "$REPO" /etc/apt/sources.list; then
    cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb ${REPO} buster main contrib non-free
deb ${REPO} buster-updates main contrib non-free
deb ${REPO} buster-backports main contrib non-free
deb http://security.debian.org/ buster/updates main contrib non-free
EOF
    echo -e "\033[1;33mRepository Debian 10 telah ditambahkan.\033[0m"
fi

# Update sistem dan install DHCP server
apt update -y
apt install isc-dhcp-server -y

# Konfigurasi interface DHCP
echo 'INTERFACESv4="enp0s8"' > /etc/default/isc-dhcp-server

# Konfigurasi file dhcpd.conf
cat > /etc/dhcp/dhcpd.conf << EOF
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 10.10.20.0 netmask 255.255.255.0 {
  range 10.10.20.10 10.10.20.100;
  option routers 10.10.20.1;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 8.8.8.8;
}
EOF

# Konfigurasi IP statik
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 172.17.20.2
    netmask 255.255.255.0
    gateway 172.17.20.1
    dns-nameservers 8.8.8.8

auto enp0s8
iface enp0s8 inet static
    address 10.10.20.1
    netmask 255.255.255.0
EOF

# Restart jaringan dan DHCP server
systemctl restart networking
systemctl restart isc-dhcp-server

echo -e "\033[1;32mKonfigurasi selesai. DHCP Server siap digunakan.\033[0m"
