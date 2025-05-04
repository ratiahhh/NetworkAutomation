echo "[+] Install dan konfigurasi DNS"
apt install bind9 -y

cat >> /etc/bind/named.conf.local << EOF
zone "networking.net" {
    type master;
    file "/etc/bind/db.networking.net";
};

zone "itclub.com" {
    type master;
    file "/etc/bind/db.itclub.com";
};
EOF

cp /etc/bind/db.local /etc/bind/db.networking.net
cp /etc/bind/db.local /etc/bind/db.itclub.com

sed -i 's/localhost/networking.net./' /etc/bind/db.networking.net
sed -i 's/127.0.0.1/10.10.1.1/' /etc/bind/db.networking.net

sed -i 's/localhost/itclub.com./' /etc/bind/db.itclub.com
sed -i 's/127.0.0.1/10.10.1.1/' /etc/bind/db.itclub.com 
