#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Jalankan script sebagai root."
  exit
fi

echo "Sedang Update & Install Paket yang Diperlukan nih..."
apt update && apt install -y isc-dhcp-server vlan net-tools

echo "Lagi Proses Konfigurasi Cik..."
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
        - 192.168.31.1/24
EOF

echo "Menerapkan konfigurasi netplan..."
netplan apply

echo "Konfigurasi DHCP server..."
cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.31.0 netmask 255.255.255.0 {
  range 192.168.31.100 192.168.10.200;
  option routers 192.168.31.1;
  option broadcast-address 192.168.31.255;
}
EOF

echo "Lagi Restart DHCP server nihh..."
systemctl restart isc-dhcp-server

echo "Konfigurasi Ubuntu Donnnn!"
