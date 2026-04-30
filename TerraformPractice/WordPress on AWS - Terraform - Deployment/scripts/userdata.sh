#!/bin/bash
dnf update -y
dnf install -y httpd mariadb114-server.x86_64 php php-mysqlnd wget tar
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb
mysql -e "CREATE DATABASE wordpress;"
mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html