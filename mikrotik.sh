#!/usr/bin/expect

# Mulai sesi telnet ke MikroTik
spawn telnet 192.168.157.128 30023
log_user 1
set timeout 30

# Menangani login
expect -re "(L|l)ogin: " { send "admin\r" }
expect -re "(P|p)assword: " { send "\r" }

# Menangani prompt setelah login
expect {
    -re "(MikroTik>)" {
        puts "Login berhasil. Prompt MikroTik terdeteksi."
    }
    timeout {
        puts "Error: Timeout setelah login. Periksa koneksi atau konfigurasi MikroTik."
        exit 1
    }
}

# Perintah konfigurasi
send "/ip address add address=192.168.200.1/24 interface=ether2\r"
expect ">"
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"
expect ">"
send "/quit\r"
expect eof
