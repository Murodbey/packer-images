#!/bin/bash
#Install WordPress on a CentOS 7 VPS

#Set variables and create database

clear
echo -n "Enter your MySQL root password: "
read -s rootpass
echo ""
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser: " userpass
mysql -uroot -p$rootpass <<MYSQL_SCRIPT
CREATE DATABASE $dbname CHARACTER SET utf8 COLLATE utf8_general_ci;
DELETE FROM mysql.user WHERE user='$dbuser' AND host = 'localhost';
FLUSH PRIVILEGES;
CREATE USER $dbuser@localhost;
GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$userpass';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "Database created. Starting installation!"
sleep 2

#Download, install, and configuration of WordPress

read -p "Enter your server's public IP address: " address
read -r -p "Enter your WordPress URL [e.g. mydomain.com]: " wordurl
mkdir -p /var/www/html/$wordurl
cd /tmp/
wget -q http://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz -C /var/www/html/
rm -f /tmp/latest.tar.gz
mv /var/www/html/wordpress /var/www/html/$wordurl
cd /var/www/html/$wordurl
sed -e "s/database_name_here/"$dbname"/" -e "s/username_here/"$dbuser"/" -e "s/password_here/"$userpass"/" wp-config-sample.php > wp-config.php
sudo chown apache: -R /var/www/html/$wordurl
sudo systecmtl restart httpd.service
#Create a Virtual Host

echo "

<VirtualHost $address:80>
 ServerName www.$wordurl
 DocumentRoot "/var/www/html/$wordurl"
 DirectoryIndex index.php
 Options FollowSymLinks
 ErrorLog logs/$wordurl-error_log
 CustomLog logs/$wordurl-access_log common
</VirtualHost>

" >> /etc/httpd/conf/httpd.conf

#Create .htaccess file

echo "

# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress

" sudo >> /var/www/html/$wordurl/.htaccess

systemctl restart httpd

echo "Continue your installation at http://www.$wordurl/wp-admin/install.php"

#End of script