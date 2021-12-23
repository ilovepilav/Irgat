#!/bin/bash

# Getting domain and mysql data from user
echo "Enter Domain with Extension (Ex: test.com)"
read WEBSITE_NAME
echo "Enter Database Name (Ex: testdb)"
read DATABASE_NAME
echo "Enter Database User (Ex: testuser)"
read USER_NAME
echo "Enter Password (Ex: test1234)"
read PASSWORD

# Getting Cloudflare Origin SSL certificate details for
# using Cloudflare Strict Mode SSL
echo "Paste Cloudflare Origin Certificate and wait :)"
IFS= read CLOUDFLARE_ORIGIN
echo $CLOUDFLARE_ORIGIN >> $WEBSITE_NAME.pem
while IFS= read -t 2 CLOUDFLARE_ORIGIN
do
    echo $CLOUDFLARE_ORIGIN >> $WEBSITE_NAME.pem
done
echo "Thanks!"

echo "Paste Cloudflare Private Key and wait :)"
IFS= read CLOUDFLARE_PRIVATE
echo $CLOUDFLARE_PRIVATE >> $WEBSITE_NAME.key
while IFS= read -t 2 CLOUDFLARE_PRIVATE
do
    echo $CLOUDFLARE_PRIVATE >> $WEBSITE_NAME.key
done
echo "Thanks!"

# Creating folders
mkdir -p /var/www/${WEBSITE_NAME}
mkdir -p /var/www/${WEBSITE_NAME}/public_html
mkdir -p /etc/cloudflare

# Moving cloudflare key and certificate to proper folders
# we will use this folders in apache vhost config later on
mv $WEBSITE_NAME.pem /etc/cloudflare/
mv $WEBSITE_NAME.key /etc/cloudflare/

# Downloading and installing wordpress' latest version
cd /var/www/${WEBSITE_NAME}
wget http://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz
mv wordpress/* public_html/
rm latest.tar.gz
rmdir wordpress
cd public_html

# Applying given mysql credentials to wp-config
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DATABASE_NAME}/g" wp-config.php
sed -i "s/username_here/${USER_NAME}/g" wp-config.php
sed -i "s/password_here/${PASSWORD}/g" wp-config.php

# Adjusting proper file and folder permissions 
chown -R www-data:www-data /var/www/$WEBSITE_NAME
find /var/www/$WEBSITE_NAME -type d -exec chmod 755 {} \;
find /var/www/$WEBSITE_NAME -type f -exec chmod 644 {} \;
chmod 400 wp-config.php

# Creating mysql database, user and giving right permissions
mysql -u root -e "CREATE DATABASE ${DATABASE_NAME}";
mysql -u root -e "CREATE USER ${USER_NAME}@localhost IDENTIFIED BY '${PASSWORD}';"
mysql -u root -e "GRANT ALL ON ${DATABASE_NAME}.* TO '${USER_NAME}'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Creating apache2 config files
touch /etc/apache2/sites-available/${WEBSITE_NAME}.conf
file=/etc/apache2/sites-available/${WEBSITE_NAME}.conf

# Some spagetti code for building apache2 config
echo "<VirtualHost *:80>" >> $file
echo "    ServerName ${WEBSITE_NAME}" >> $file
echo "    ServerAlias www.${WEBSITE_NAME}" >> $file
echo "    DocumentRoot /var/www/${WEBSITE_NAME}/public_html" >> $file
echo "" >> $file
echo "    <Directory /var/www/${WEBSITE_NAME}/public_html>" >> $file
echo "        Options FollowSymLinks" >> $file
echo "        AllowOverride Limit Options FileInfo" >> $file
echo "        DirectoryIndex index.php" >> $file
echo "        Require all granted" >> $file
echo "    </Directory>" >> $file
echo "    <Directory /var/www/${WEBSITE_NAME}/public_html/wp-content>" >> $file
echo "        Options FollowSymLinks" >> $file
echo "        Require all granted" >> $file
echo "    </Directory>" >> $file
echo "</VirtualHost>" >> $file
echo "" >> $file
echo "<VirtualHost *:443>" >> $file
echo "" >> $file
echo "    ServerName ${WEBSITE_NAME}" >> $file
echo "    ServerAlias www.${WEBSITE_NAME}" >> $file
echo "    DocumentRoot /var/www/${WEBSITE_NAME}/public_html" >> $file
echo "" >> $file
echo "    SSLEngine on" >> $file
echo "    SSLCertificateFile /etc/cloudflare/${WEBSITE_NAME}.pem" >> $file
echo "    SSLCertificateKeyFile /etc/cloudflare/${WEBSITE_NAME}.key" >> $file
echo "" >> $file
echo "</VirtualHost>" >> $file

# Activating created config for given website and restart apache2
a2ensite $WEBSITE_NAME.conf
systemctl reload apache2
systemctl restart apache2

echo "Ignore apache reload message we have already done it !"
echo "Enjoy!"