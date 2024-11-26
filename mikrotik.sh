#!/bin/bash

# Script Konfigurasi MikroTik dengan Netmiko
echo "Memulai Otomasi Konfigurasi MikroTik"

cat <<EOF > mikrotik_config.py
from netmiko import ConnectHandler

# Konfigurasi perangkat MikroTik
mikrotik_device = {
    'device_type': 'mikrotik_routeros',
    'host': '192.168.157.130',  # IP PNET MikroTik
    'username': 'admin',
    'password': '',
}

# Koneksi ke perangkat MikroTik
net_connect = ConnectHandler(**mikrotik_device)

# Konfigurasi VLAN dan IP
commands = [
    '/interface vlan add name=vlan10 vlan-id=10 interface=ether1',
    '/ip address add address=192.168.31.3/24 interface=vlan10',
    '/ip dhcp-client add interface=ether1',
    '/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1',
]
output = net_connect.send_config_set(commands)
print(output)

# Tutup koneksi
net_connect.disconnect()
EOF

echo "Konfigurasi MikroTik selesai."
