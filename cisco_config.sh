sshpass -p "$PASSWORD_SWITCH" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $USER_SWITCH@$SWITCH_IP <<EOF
enable
configure terminal
vlan $VLAN_ID
name VLAN10
exit
interface $INTERFACE
switchport mode access
switchport access vlan $VLAN_ID
exit
end
write memory
EOF

if [ $? -ne 0 ]; then
  echo "✘ Gagal mengonfigurasi Cisco Switch. Periksa koneksi SSH atau konfigurasi VLAN."
  exit 1
fi
sshpass -p "$PASSWORD_SWITCH" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $USER_SWITCH@$SWITCH_IP <<EOF
enable
configure terminal
vlan $VLAN_ID
name VLAN10
exit
interface $INTERFACE
switchport mode access
switchport access vlan $VLAN_ID
exit
end
write memory
EOF

if [ $? -ne 0 ]; then
  echo "✘ Gagal mengonfigurasi Cisco Switch. Periksa koneksi SSH atau konfigurasi VLAN."
  exit 1
fi
