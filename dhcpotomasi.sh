#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Jalankan script ini sebagai root!"
  exit 1
fi

# Fungsi untuk memeriksa status jaringan
check_network_status() {
  local interface=$1
  status=$(ip link show "$interface" | grep "state UP")
  if [ -z "$status" ]; then
    echo "Interface $interface tidak aktif, mencoba mengaktifkannya..."
    ip link set "$interface" up
    sleep 2
  else
    echo "Interface $interface sudah aktif."
  fi
}

echo "Memastikan jaringan dalam keadaan UP..."
# Periksa dan aktifkan interface jaringan
check_network_status eth0
check_network_status eth1

echo "Memperbarui dan menginstal paket yang diperlukan..."
apt update && apt install -y isc-dhcp-server vlan net-tools

echo "Membuat konfigurasi Netplan untuk VLAN..."
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

echo "Menerapkan konfigurasi Netplan..."
netplan try
if [ $? -ne 0 ]; then
  echo "Ada kesalahan pada konfigurasi Netplan. Silakan cek file /etc/netplan/01-netcfg.yaml."
  exit 1
fi

netplan apply
echo "Konfigurasi jaringan berhasil diterapkan!"

echo "Menyiapkan konfigurasi DHCP server..."
cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.10.0 netmask 255.255.255.0 {
  range 192.168.10.100 192.168.10.200;
  option routers 192.168.10.1;
  option broadcast-address 192.168.10.255;
}
EOF

# Restart layanan DHCP server
echo "Restarting DHCP server..."
systemctl restart isc-dhcp-server
if [ $? -ne 0 ]; then
  echo "Gagal memulai DHCP server. Periksa konfigurasi di /etc/dhcp/dhcpd.conf."
  exit 1
fi

echo "Konfigurasi selesai! Jaringan seharusnya berfungsi dengan baik."
