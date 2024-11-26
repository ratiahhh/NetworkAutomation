#!/bin/bash

# Script Konfigurasi Cisco Switch dengan Netmiko
echo "Memulai Otomasi Konfigurasi Cisco Switch"

cat <<EOF > cisco.py
from netmiko import ConnectHandler

# Konfigurasi perangkat Cisco
cisco_device = {
    'device_type': 'cisco_ios',
    'host': '192.168.157.128',  # IP PNET Cisco
    'username': 'admin',
    'password': 'admin',
    'secret': 'admin',  # Enable password
}

# Koneksi ke perangkat Cisco
net_connect = ConnectHandler(**cisco_device)
net_connect.enable()

# Konfigurasi Telnet dan VLAN
commands = [
    # Konfigurasi akses Telnet dan user credentials
    'line vty 0 4',
    'password admin',
    'login',
    'exit',
    
    # Konfigurasi username dan password untuk SSH/Telnet
    'username admin privilege 15 password admin',
    'enable secret admin',

    # Aktifkan akses Telnet
    'ip telnet source-interface vlan1',

    # VLAN 10 konfigurasi
    'vlan 10',
    'name VLAN_10',
    'interface vlan 10',
    'ip address 192.168.31.2 255.255.255.0',
    'no shutdown',

    # Assign VLAN ke port
    'interface gigabitEthernet 0/1',
    'switchport mode access',
    'switchport access vlan 10',
    'exit'
]

# Kirim konfigurasi
output = net_connect.send_config_set(commands)
print(output)

# Simpan konfigurasi
net_connect.save_config()

# Tutup koneksi
net_connect.disconnect()
EOF

# Jalankan Python script untuk Cisco
python3 cisco.py

echo "Konfigurasi Cisco selesai."
