#!/usr/bin/expect

# Mulai sesi Telnet ke MikroTik
spawn telnet 192.168.157.128 30023
log_user 1
set timeout 20

# Menangani Login
expect {
    -re "(L|l)ogin: " { 
        send "admin\r" 
    }
    timeout {
        puts "Error: Timeout saat menunggu prompt login."
        exit 1
    }
}

# Menangani Password Prompt
expect {
    -re "(P|p)assword: " {
        send "\r"   ;# Password default kosong
    }
    timeout {
        puts "Error: Timeout saat menunggu prompt password."
        exit 1
    }
}

# Menangani lisensi atau permintaan password baru
expect {
    -re "Do you want to see the software license.*" {
        send "n\r"
        exp_continue
    }
    -re "new password>" {
        send "123\r"
        expect "repeat new password>" { send "123\r" }
    }
    -re ".*>" {
        puts "Login berhasil ke MikroTik."
    }
    timeout {
        puts "Error: Timeout setelah login."
        exit 1
    }
}

# Pastikan berada di prompt MikroTik sebelum melanjutkan konfigurasi
expect ">" { puts "Memulai konfigurasi MikroTik." }

# Perintah Konfigurasi MikroTik

# Menambahkan IP Address untuk ether2
send "/ip address add address=192.168.200.1/24 interface=ether2\r"
expect ">" { puts "IP Address untuk ether2 berhasil ditambahkan." }

# Menambahkan NAT Masquerade
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"
expect ">" { puts "NAT Masquerade berhasil ditambahkan." }

# Menambahkan Rute Default (Internet Gateway)
send "/ip route add gateway=192.168.31.1\r"
expect ">" { puts "
