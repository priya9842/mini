#!/usr/bin/env bash

#UPDATING PACKAGES
echo -e "######## \e[32mUPDATING PACKAGES\e[39m ########"
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null
echo -e ""

#SETTING TIME ZONE
echo -e "######## \e[32mSETTING TIME ZONE\e[39m ########"
echo "Europe/London" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

#INSTALLING BASE PACKAGES
echo -e "######## \e[32mINSTALLING BASE PACKAGES\e[39m ########"
echo -e ""
sudo apt-get install -y pwgen unzip apache2 php7.0-mcrypt memcached php php-mysql php-pear nodejs libapache2-mod-php php-curl php-imagick php-sqlite3 -qq > /dev/null
sudo pear channel-discover pear.phing.info
wget http://files.scripting.online/ministra/phing-2.16.1.tgz
sudo pear install phing-2.16.1.tgz
echo -e ""


#CONFIGURING MYSQL
echo -e "######## \e[32mCONFIGURING MYSQL\e[39m ########"
echo -e ""
echo "sql_mode=\"\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf
stalkerpass=$(pwgen 14 1)
mysql -u root -p$mysqlpass -e "create database stalker_db;"
mysql -u root -p$mysqlpass -e "GRANT ALL PRIVILEGES ON stalker_db.* TO stalker@localhost IDENTIFIED BY '$stalkerpass' WITH GRANT OPTION;"
sudo systemctl restart mysql
echo -e ""

#CONFIGURING PHP
echo -e "######## \e[32mCONFIGURING PHP\e[39m ########"
echo -e ""
phpenmod mcrypt
echo "short_open_tag = On" >> /etc/php/7.0/apache2/php.ini
touch /var/www/html/index.php
sudo rm /var/www/html/index.html

#CONFIGURING APACHE
echo -e "######## \e[32mCONFIGURING APACHE\e[39m ########"
echo -e ""
a2enmod rewrite
sudo apt-get -qq purge -y libapache2-mod-php5filter
cat /dev/null > /etc/apache2/sites-available/000-default.conf
echo "<VirtualHost *:80>" > /etc/apache2/sites-available/000-default.conf
echo "        ServerAdmin webmaster@localhost" >> /etc/apache2/sites-available/000-default.conf
echo "        DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf
echo "        <Directory /var/www/html/stalker_portal/>" >> /etc/apache2/sites-available/000-default.conf
echo "                Options -Indexes -MultiViews" >> /etc/apache2/sites-available/000-default.conf
echo "                AllowOverride ALL" >> /etc/apache2/sites-available/000-default.conf
echo "                Require all granted" >> /etc/apache2/sites-available/000-default.conf
echo "        </Directory>" >> /etc/apache2/sites-available/000-default.conf
echo "        ErrorLog \${APACHE_LOG_DIR}/stalker_portal_error.log" >> /etc/apache2/sites-available/000-default.conf
echo "        CustomLog \${APACHE_LOG_DIR}/stalker_portal_access.log combined" >> /etc/apache2/sites-available/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2
echo -e ""

#INSTALLING NPM
echo -e "######## \e[32mINSTALLING NPM\e[39m ########"
echo -e ""
sudo apt-get install -y npm -qq > /dev/null
npm config set loglevel warn
sudo npm install --silent -g npm@2.15.11
sudo ln -s /usr/bin/nodejs /usr/bin/node
echo -e ""

#INSTALLING MINISTRA
echo -e "######## \e[32mINSTALLING MINISTRA\e[39m ########"
echo -e ""
wget -q -P /var/www/html/ https://files.scripting.online/ministra/ministra-5.5.0.zip
unzip -q /var/www/html/ministra-5.5.0.zip -d /var/www/html
sudo rm /var/www/html/ministra-5.5.0.zip

echo "[database]" > /var/www/html/stalker_portal/server/custom.ini
echo "mysql_host = localhost" >> /var/www/html/stalker_portal/server/custom.ini
echo "mysql_port = 3306" >> /var/www/html/stalker_portal/server/custom.ini
echo "mysql_user = stalker" >> /var/www/html/stalker_portal/server/custom.ini
echo "mysql_pass = $stalkerpass" >> /var/www/html/stalker_portal/server/custom.ini
echo "db_name = stalker_db" >> /var/www/html/stalker_portal/server/custom.ini
echo "" >> /var/www/html/stalker_portal/server/custom.ini
echo "[locales]" >> /var/www/html/stalker_portal/server/custom.ini
echo "default_locale = en_GB.utf8" >> /var/www/html/stalker_portal/server/custom.ini

rm -rf /var/www/html/stalker_portal/admin/vendor
wget -q -P /var/www/html/stalker_portal/admin/ https://files.scripting.online/ministra/vendor.tar
(cd /var/www/html/stalker_portal/admin && tar -xf vendor.tar)
(cd /var/www/html/stalker_portal/deploy/ && sudo phing)
echo -e ""

#INSTALLATION FINISHED
echo -e "######## \e[32mINSTALLATION FINISHED\e[39m ########"
echo -e ""
echo -e "Congratulations, installion is complete!"
echo -e ""

