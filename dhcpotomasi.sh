#!/bin/bash

# Otomasi Dimulai
echo "Memulai Otomasi Ubuntu DHCP Server, VLAN, dan IP PNET"

# Repo Kartolo
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

sudo apt update

# Konfigurasi Network (Netplan) dengan IP PNET
cat <<EOT > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
    eth1:
      dhcp4: no
      addresses:
        - 192.168.157.128/24  # IP PNET untuk eth1
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.31.1/24
EOT

# Terapkan konfigurasi jaringan
echo "Menerapkan konfigurasi jaringan..."
netplan apply

# Validasi IP Address
echo "Validasi IP Address yang dikonfigurasi..."
ip a

# Pastikan IP Forwarding Aktif
echo "Mengaktifkan IP forwarding..."
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# NAT Masquerading untuk eth0 (Internet)
echo "Menambahkan NAT Masquerading untuk koneksi internet..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo apt install iptables-persistent -y

# Konfigurasi DHCP Server
echo "Menginstal dan Mengonfigurasi DHCP Server untuk VLAN..."
sudo apt install isc-dhcp-server -y

cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
subnet 192.168.31.0 netmask 255.255.255.0 {
  range 192.168.31.2 192.168.31.254;
  option domain-name-servers 8.8.8.8;
  option subnet-mask 255.255.255.0;
  option routers 192.168.31.1;
  option broadcast-address 192.168.31.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF

# DHCP Server untuk VLAN
echo 'INTERFACESv4="eth1.10"' | sudo tee /etc/default/isc-dhcp-server
sudo systemctl restart isc-dhcp-server

# Instal SSH Server
echo "Menginstal SSH Server..."
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl restart ssh

# Buka Port SSH di Firewall
echo "Mengizinkan koneksi SSH melalui firewall..."
sudo ufw allow ssh
sudo ufw enable

# Tambahkan IP Static Route (PNET ke Cisco dan MikroTik)
echo "Menambahkan static route untuk memastikan konektivitas dengan IP PNET..."
sudo ip route add 192.168.157.129/32 dev eth1   # Route ke Cisco
sudo ip route add 192.168.157.130/32 dev eth1   # Route ke MikroTik

# Tes Konektivitas ke IP PNET
echo "Tes konektivitas ke perangkat lain di jaringan PNET..."
ping -c 4 192.168.157.129  # Ping Cisco
ping -c 4 192.168.157.130  # Ping MikroTik

echo "Konfigurasi Ubuntu selesai. DHCP Server, VLAN, IP PNET, dan NAT siap digunakan."
