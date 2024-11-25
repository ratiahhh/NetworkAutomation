from netmiko import ConnectHandler

# Konfigurasi perangkat Cisco
cisco_device = {
    "device_type": "cisco_ios",
    "host": "192.168.31.2",  # Ganti dengan IP perangkat Cisco
}

# Parameter VLAN
vlan_id = 10
vlan_ip = "192.168.31.2"
vlan_subnet_mask = "255.255.255.0"
default_gateway = "192.168.31.1"

# Perintah konfigurasi untuk perangkat Cisco
commands = [
    "conf t",
    f"vlan {vlan_id}",
    "exit",
    f"interface vlan {vlan_id}",
    f"ip address {vlan_ip} {vlan_subnet_mask}",
    "no shutdown",
    f"ip default-gateway {default_gateway}",
    "interface GigabitEthernet0/1",  # Port yang digunakan, ganti sesuai topologi
    "switchport mode access",
    f"switchport access vlan {vlan_id}",
    "no shutdown",
    "exit",
    "write memory",
]

# Koneksi ke perangkat Cisco dan eksekusi perintah
try:
    print("Menghubungkan ke perangkat Cisco...")
    net_connect = ConnectHandler(**cisco_device)
    print("Berhasil terhubung. Mengirim konfigurasi...")
    output = net_connect.send_config_set(commands)
    print(output)
    print("Konfigurasi selesai. Menyimpan konfigurasi...")
    net_connect.save_config()
    print("Konfigurasi berhasil disimpan.")
    net_connect.disconnect()
except Exception as e:
    print(f"Terjadi kesalahan: {e}")
