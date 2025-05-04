# Menginstall dan Mengkonfigurasi Mail Server

echo "[+] Setup Web Server"
apt install apache2 -y

mkdir -p /var/www/networking.net
mkdir -p /var/www/itclub.com

echo "Selamat Datang Di Website NETWORKING Kelas 11" > /var/www/networking.net/index.html
echo "Selamat Datang Di Website IT CLUB SMKN 5 Bandung" > /var/www/itclub.com/index.html

cat > /etc/apache2/sites-available/networking.net.conf << EOF
<VirtualHost *:80>
    ServerName www.networking.net
    DocumentRoot /var/www/networking.net
</VirtualHost>
EOF

cat > /etc/apache2/sites-available/itclub.com.conf << EOF
<VirtualHost *:80>
    ServerName www.itclub.com
    DocumentRoot /var/www/itclub.com
</VirtualHost>
EOF

a2ensite networking.net.conf
a2ensite itclub.com.conf
systemctl reload apache2
