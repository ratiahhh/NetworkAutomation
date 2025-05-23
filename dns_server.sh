#!/bin/bash

echo "===================================="
echo "===     MENGINSTAL BIND9         ==="
echo "===================================="
apt update && apt install -y bind9 dnsutils

echo "===================================="
echo "===  MENYIAPKAN DIREKTORI ZONA  ==="
echo "===================================="
mkdir -p /etc/bind/zones

echo "=============================================="
echo "=== KONFIGURASI ZONA DI NAMED.CONF.LOCAL   ==="
echo "=============================================="
echo "Konfigurasi berhasil..."
cat <<EOF > /etc/bind/named.conf.local
zone "itclub.com" {
    type master;
    file "/etc/bind/db.itclub.com";
};

zone "networking.net" {
    type master;
    file "/etc/bind/db.networking.net";
};

zone "10.10.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF

echo "=============================================="
echo "=== MEMBUAT FILE ZONA UNTUK ITCLUB.COM...  ==="
echo "=============================================="
cat <<EOF > /etc/bind/db.itclub.com
\$TTL    604800
@       IN      SOA     itclub.com. root.itclub.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         602800 )       ; Negative Cache TTL
;
        IN      NS      itclub.com.
        IN      A       10.10.10.1
www     IN      A       10.10.10.1
EOF

echo "====================================================="
echo "=== MEMBUAT FILE ZONA UNTUK NETWORKING.NET...    ==="
echo "====================================================="
cat <<EOF > /etc/bind/db.networking.net
\$TTL    604800
@       IN      SOA     networking.net. root.networking.net. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         602800 )       ; Negative Cache TTL
;
        IN      NS      networking.net.
        IN      A       10.10.10.1
EOF
