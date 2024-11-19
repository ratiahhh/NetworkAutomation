# Parameter koneksi ke Cisco Switch
cisco_switch = {
    'device_type': 'cisco_ios',
    'host': '192.168.31.2',  
}

# Konfigurasi VLAN dan Interface
vlan_id = 10
vlan_name = 'VLAN10'
interface = 'Ethernets1'  

try:
    # Membuka koneksi ke switch
    net_connect = ConnectHandler(cisco_switch)

    # Memasukkan perintah konfigurasi VLAN dan interface
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
    print("Output konfigurasi Cisco Switch:")
    print(output)

    # Menyimpan konfigurasi
    save_output = net_connect.save_config()
    print("Konfigurasi berhasil disimpan.")
    print(save_output)

    # Menutup koneksi
    net_connect.disconnect()
except Exception as e:
    print(f"✘ Gagal mengonfigurasi Cisco Switch: {e}")
