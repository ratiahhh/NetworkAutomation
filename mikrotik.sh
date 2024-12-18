#!/usr/bin/expect

# Variabel koneksi Mikrotik
set mikrotik_ip "192.168.157.128"
set mikrotik_port "30023"
set username "admin"
set password "123"

# Timeout default
set timeout 30

# Mulai koneksi Telnet
spawn telnet $mikrotik_ip $mikrotik_port

# Menangani prompt login
expect {
    "Login: " {
        send "$username\r"
    }
    timeout {
        puts "Error: Timeout saat menunggu prompt login."
        exit 1
    }
}

# Menangani prompt password
expect {
    "Password: " {
        send "$password\r"
    }
    timeout {
        puts "Error: Timeout saat menunggu prompt password."
        exit 1
    }
}

# Verifikasi berhasil masuk ke prompt Mikrotik
expect {
    ">" {
        puts "Berhasil login ke Mikrotik!"
    }
    timeout {
        puts "Error: Timeout saat menunggu prompt Mikrotik setelah login."
        exit 1
    }
}

# Mengirim perintah konfigurasi firewall NAT
send "ip firewall nat add chain=srcnat action=masquerade out-interface=ether1\r"
expect ">"
send "ip firewall nat print\r"
expect ">"
send "quit\r"

# Tunggu hingga selesai
expect eof
