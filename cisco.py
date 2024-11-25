#!/bin/bash

# Instalasi expect jika belum tersedia
echo "Memastikan expect terpasang..."
apt update && apt install -y expect

# Variabel konfigurasi
CISCO_IP="192.168.31.2"    # IP untuk Cisco Switch
USERNAME="admin"           # Username Cisco
PASSWORD="password"        # Password Cisco

# Skrip Expect untuk konfigurasi Cisco
echo "Memulai konfigurasi Cisco Switch..."
expect << EOF
spawn telnet $CISCO_IP
expect "Username:"
send "$USERNAME\r"
expect "Password:"
send "$PASSWORD\r"
expect ">"
send "enable\r"
expect "Password:"
send "$PASSWORD\r"
expect "#"
send "configure terminal\r"
expect "(config)#"
send "vlan 10\r"
expect "(config-vlan)#"
send "name VLAN10\r"
expect "(config-vlan)#"
send "exit\r"
expect "(config)#"
send "interface e0/0\r"
expect "(config-if)#"
send "switchport mode trunk\r"
expect "(config-if)#"
send "exit\r"
expect "(config)#"
send "interface e0/1\r"
expect "(config-if)#"
send "switchport mode access\r"
expect "(config-if)#"
send "switchport access vlan 10\r"
expect "(config-if)#"
send "exit\r"
expect "(config)#"
send "end\r"
expect "#"
send "write memory\r"
expect "#"
send "exit\r"
EOF

echo "Konfigurasi Cisco Switch selesai!"
