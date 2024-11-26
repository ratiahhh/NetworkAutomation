#!/bin/bash

# Script Konfigurasi Cisco Switch dengan Netmiko
echo "Memulai Otomasi Konfigurasi Cisco Switch"

cat <<EOF > cisco_config.py
from netmiko import ConnectHandler

# Konfigurasi perangkat Cisco
cisco_device = {
    'device_type': 'cisco_ios',
    'host': '192.168.157.129',  # IP PNET Cisco
    'username': 'admin',
    'password': 'admin',
    'secret': 'admin',
}

# Koneksi ke perangkat Cisco
net_connect = ConnectHandler(**cisco_device)
net_connect.enable()

# Konfigurasi Switch
commands = [
    'vlan 10',
    'name VLAN_10',
    'interface vlan 10',
    'ip address 192.168.31.2 255.255.255.0',
    'no shutdown',
    'interface gigabitEthernet 0/1',
    'switchport mode access',
    'switchport access vlan 10',
    'exit'
]
output = net_connect.send_config_set(commands)
print(output)

# Simpan konfigurasi
net_connect.save_config()

# Tutup koneksi
net_connect.disconnect()
EOF

echo "Konfigurasi Cisco selesai."
