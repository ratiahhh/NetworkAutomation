#!/usr/bin/expect

# Definisi warna ANSI escape
set green "\033[1;32m"
set red "\033[1;31m"
set yellow "\033[1;33m"
set blue "\033[1;34m"
set reset "\033[0m"

# Fungsi untuk print berwarna
proc log {color message} {
    puts -nonewline "$color$message$::reset"
    flush stdout
}

# Mulai sesi telnet ke MikroTik
log $blue "--> Memulai koneksi Telnet ke MikroTik...\n"
spawn telnet 192.168.157.128 30016
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

# Tangani prompt lisensi jika muncul
expect {
    -re "Do you want to see the software license.*" {
        log $green "--> Menolak lisensi...\n"
        send "n\r"
    }
    "new password>" {
        log $yellow "--> Password baru diperlukan, mengatur password...\n"
        send "123\r"
    }
}

# Ubah password baru jika diminta
expect "new password>" { 
    send "123\r"
    expect "repeat new password>" { send "123\r" }
}

# Verifikasi apakah password berhasil diubah
expect {
    "Try again, error: New passwords do not match!" {
        log $red "!! Error: Password tidak cocok. Gagal login.\n"
        exit 1
    }
    ">" {
        log $green "--> Login berhasil! Mulai konfigurasi...\n"
    }
}

# Menambahkan IP Address pada interface ether2
expect ">" { 
    log $blue "--> Menambahkan IP Address pada ether2...\n"
    send "/ip address add address=192.168.200.1/24 interface=ether2\r" 
}
expect ">" { 
    log $blue "--> Menambahkan IP Address pada ether1...\n"
    send "/ip address add address=192.168.31.4/24 interface=ether1\r" 
}

# Menambahkan DHCP Server Configuration
expect ">" { 
    log $yellow "--> Menambahkan IP Pool DHCP...\n"
    send "/ip pool add name=dhcp_pool ranges=192.168.200.10-192.168.200.100\r" 
}
expect ">" { 
    log $yellow "--> Menambahkan DHCP Server...\n"
    send "/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool disabled=no\r" 
}
expect ">" { 
    log $yellow "--> Menambahkan konfigurasi jaringan DHCP...\n"
    send "/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1 dns-server=8.8.8.8,8.8.4.4\r" 
}

# Menambahkan Route untuk akses internet
expect ">" { 
    log $blue "--> Menambahkan routing untuk akses internet...\n"
    send "/ip route add dst-address=192.168.200.1/24 gateway=192.168.31.1\r" 
}

# Menambahkan NAT Masquerade untuk akses internet
expect ">" { 
    log $green "--> Menambahkan NAT Masquerade untuk akses internet...\n"
    send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r" 
}

# Keluar dari MikroTik
expect ">" { 
    log $blue "--> Mengakhiri sesi dan keluar...\n"
    send "quit\r" 
}
expect eof

log $green "--> Konfigurasi selesai. Script berhasil dijalankan!!!\n"
