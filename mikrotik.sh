#!/usr/bin/expect

# Definisi Warna ANSI
set green "\033[1;32m"
set red "\033[1;31m"
set yellow "\033[1;33m"
set blue "\033[1;34m"
set cyan "\033[1;36m"
set reset "\033[0m"

# Fungsi untuk mencetak log berwarna
proc log {color message} {
    puts -nonewline "$color$message$::reset"
    flush stdout
}

# Mulai sesi telnet ke MikroTik
log $cyan "--> Memulai koneksi Telnet ke MikroTik...\n"
spawn telnet 192.168.157.128 30014
set timeout 10

# Login otomatis
expect "Mikrotik Login: " { 
    log $yellow "--> Login sebagai admin...\n"
    send "admin\r" 
}
expect "Password: " { 
    log $yellow "--> Menggunakan password default...\n"
    send "\r" 
}

# Tangani prompt lisensi atau permintaan password baru
expect {
    -re "Do you want to see the software license.*" {
        log $green "--> Menolak lisensi...\n"
        send "n\r"
        exp_continue
    }
    "new password>" {
        log $yellow "--> Mengatur password baru...\n"
        send "123\r"
        expect "repeat new password>" { 
            send "123\r" 
        }
    }
}

# Verifikasi apakah password berhasil diubah
expect {
    "Password changed" {
        log $green "--> Password berhasil diubah.\n"
    }
    "Try again, error: New passwords do not match!" {
        log $red "!! Error: Password tidak cocok. Ulangi pengisian password.\n"
        send "123\r"
        expect "repeat new password>" { send "123\r" }
        expect "Password changed" { log $green "--> Password berhasil diubah.\n" }
    }
    ">" {
        log $green "--> Login berhasil tanpa perubahan password.\n"
    }
    timeout {
        log $red "!! Error: Timeout setelah login.\n"
        exit 1
    }
}

# Pastikan berada di prompt MikroTik sebelum melanjutkan
expect ">" { log $cyan "--> Konfigurasi MikroTik dimulai.\n" }

# Menambahkan IP Address untuk ether2
log $blue "--> Menambahkan IP Address pada ether2...\n"
send "/ip address add address=192.168.200.1/24 interface=ether2\r"
expect ">" 

# Menambahkan NAT Masquerade
log $blue "--> Menambahkan NAT Masquerade...\n"
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"
expect ">"

# Menambahkan Rute Default (Internet Gateway)
log $blue "--> Menambahkan Rute Default...\n"
send "/ip route add gateway=192.168.31.1\r"
expect ">"

# Menambahkan pool DHCP
log $blue "--> Menambahkan pool DHCP...\n"
send "/ip pool add name=dhcp_pool ranges=192.168.200.2-192.168.200.100\r"
expect ">"

# Menambahkan konfigurasi DHCP server
log $blue "--> Menambahkan konfigurasi DHCP Server...\n"
send "/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool disabled=no\r"
expect ">"

# Menambahkan konfigurasi jaringan DHCP
log $blue "--> Menambahkan konfigurasi jaringan DHCP...\n"
send "/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1 dns-server=8.8.8.8,8.8.4.4\r"
expect ">"

# Keluar dari MikroTik
log $cyan "--> Mengakhiri sesi dan keluar dari MikroTik...\n"
send "quit\r"
expect eof

log $green "--> Konfigurasi selesai. Script berhasil dijalankan!\n"
