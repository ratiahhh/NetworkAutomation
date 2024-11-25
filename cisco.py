from netmiko import ConnectHandler
import time

# Konfigurasi perangkat Cisco
cisco_device = {
    "device_type": "cisco_ios",  # Tipe perangkat Cisco
    "host": "192.168.31.2",     # IP perangkat Cisco
    "port": 22,                 # Port SSH default
    "username": "",             # Kosong karena tidak menggunakan autentikasi username
    "password": "",             # Kosong karena tidak menggunakan autentikasi password
}

# Perintah konfigurasi SSH, VLAN, dan lainnya
commands = [
    "conf t",
    "hostname Switch",                            
    "ip domain-name local",                      
    "crypto key generate rsa modulus 3077",      
    "ip ssh version 2",                           
    "line vty 0 4",                               
    "transport input ssh",
    "no login",
    "exit",
    f"vlan 10",
    "exit",
    "interface ethernet0/0",
    "switch trunk encapsulation dot1q",
    "switchport mode trunk",
    "exit",
    "interface ethernet0/1",
    "switchport mode access",
    "switchport access vlan 10",
    "exit",
    "write memory",
]

# Fungsi untuk mencoba koneksi SSH
def test_connection(device):
    print(f"Menguji koneksi SSH ke {device['host']} di port {device['port']}...")
    try:
        net_connect = ConnectHandler(**device)
        print("Koneksi SSH berhasil!")
        return net_connect
    except Exception as e:
        print(f"Kesalahan koneksi: {e}")
        return None

# Fungsi untuk mengirim perintah konfigurasi
def configure_device(net_connect, config_commands):
    try:
        print("Mengirim konfigurasi ke perangkat Cisco...")
        output = net_connect.send_config_set(config_commands)
        print("Konfigurasi berhasil dikirim!")
        print(output)
        net_connect.save_config()
        print("Konfigurasi berhasil disimpan.")
    except Exception as e:
        print(f"Terjadi kesalahan saat mengirim konfigurasi: {e}")

# Eksekusi utama
if __name__ == "__main__":
    # Koneksi awal untuk konfigurasi otomatis
    print("Memulai konfigurasi otomatis perangkat Cisco...")
    net_connect = test_connection(cisco_device)
    if net_connect:
        configure_device(net_connect, commands)
        net_connect.disconnect()
        print("Proses konfigurasi selesai. Semua otomatis!")
    else:
        print("Pastikan SSH aktif dan port yang digunakan benar.")
