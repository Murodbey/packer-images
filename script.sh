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
mysql_secure_installation -uroot -p$rootpass <<MYSQL_SCRIPT
CREATE DATABASE $dbname CHARACTER SET utf8 COLLATE utf8_general_ci;
DELETE FROM mysql.user WHERE user='$dbuser' AND host = 'localhost';
FLUSH PRIVILEGES;
CREATE USER $dbuser@localhost;
GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$userpass';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "Database created. Starting installation!"
sleep 2

systemctl restart httpd

#End of script