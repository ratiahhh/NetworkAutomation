#!/bin/bash



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

# Konfigurasi IP statik untuk kedua adapter
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 172.17.20.2
    netmask 255.255.255.0
    gateway 172.17.20.1
    dns-nameserver 8.8.8.8

auto enp0s8
iface enp0s8 inet static
    address 10.10.20.1
    netmask 255.255.255.0
EOF

# Restart service dan jaringan
systemctl restart networking
systemctl restart isc-dhcp-server
