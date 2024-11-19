# Parameter koneksi
switch = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.1',  # Ganti dengan IP switch Anda
    'username': 'admin',    # Ganti dengan username switch Anda
    'password': 'password', # Ganti dengan password switch Anda
}

# Parameter konfigurasi
vlan_id = 10
vlan_name = 'VLAN10'
interface = 'GigabitEthernet1/0/1'  # Ganti dengan interface yang sesuai

try:
    # Membuka koneksi
    net_connect = ConnectHandler(**switch)

    # Memasukkan perintah konfigurasi
    config_commands = [
        f'vlan {vlan_id}',
        f'name {vlan_name}',
        'exit',
        f'interface {interface}',
        'switchport mode access',
        f'switchport access vlan {vlan_id}',
        'exit',
    ]
    output = net_connect.send_config_set(config_commands)
    print(output)

    # Menyimpan konfigurasi
    save_output = net_connect.save_config()
    print(save_output)

    # Menutup koneksi
    net_connect.disconnect()
    print("✔ Konfigurasi berhasil diterapkan dan disimpan.")
except Exception as e:
    print(f"✘ Gagal mengonfigurasi Cisco Switch: {e}")
