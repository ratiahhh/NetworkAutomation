
#!/bin/bash

# Variabel Konfigurasi
SWITCH_IP="192.168.31.35"       # IP Cisco Switch
USER_SWITCH="root"              # Username SSH untuk Cisco Switch
PASSWORD_SWITCH="root"          # Password untuk Cisco Switch
VLAN_ID=10                      # VLAN ID yang ingin dibuat
VLAN_NAME="VLAN10"              # Nama VLAN
INTERFACE="e0/1"                # Interface yang akan diakses VLAN

# Warna untuk Tampilan
RED='\033[31m'
GREEN='\033[32m'
CYAN='\033[36m'
RESET='\033[0m'

# Fungsi untuk Menampilkan Status
print_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Konfigurasi Cisco Switch berhasil!${RESET}"
  else
    echo -e "${RED}✘ Gagal mengonfigurasi Cisco Switch!${RESET}"
    exit 1
  fi
}

echo -e "${CYAN}Memulai konfigurasi Cisco Switch...${RESET}"

# Login ke Cisco Switch dan lakukan konfigurasi VLAN
sshpass -p "$PASSWORD_SWITCH" ssh -o StrictHostKeyChecking=no $USER_SWITCH@$SWITCH_IP <<EOF
enable
configure terminal
vlan $VLAN_ID
name $VLAN_NAME
exit
interface $INTERFACE
switchport mode access
switchport access vlan $VLAN_ID
exit
end
write memory
EOF

# Periksa Status Konfigurasi
print_status
