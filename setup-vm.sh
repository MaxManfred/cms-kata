#!/bin/bash

# get user input: MySQL root password
while [ -z "$MYSQL_ROOT_PASSWORD" ]
do
    read -p 'Please set MySQL root password: ' MYSQL_ROOT_PASSWORD
done
    echo "MySQL root password will be set to $MYSQL_ROOT_PASSWORD"

# get user input: Joomla application database
while [ -z "$JOOMLA_DATABASE" ]
do
    read -p 'Please set Joomla database: ' JOOMLA_DATABASE
done
    echo "Joomla database will be set to $JOOMLA_DATABASE"

# get user input: Joomla application user name
while [ -z "$JOOMLA_USER_NAME" ]
do
    read -p 'Please set Joomla user name: ' JOOMLA_USER_NAME
done
    echo "Joomla user name will be set to $JOOMLA_USER_NAME"

# get user input: Joomla application user password
while [ -z "$JOOMLA_USER_PASSWORD" ]
do
    read -p 'Please set Joomla user password: ' JOOMLA_USER_PASSWORD
done
    echo "Joomla user name will be set to $JOOMLA_USER_PASSWORD"

# get user input: Joomla application version to install
while [ -z "$JOOMLA_VERSION" ]
do
    read -p 'Please set Joomla version (latest being 3-9-11): ' JOOMLA_VERSION
done
    echo "Joomla version will be set to $JOOMLA_VERSION"

# update system
sudo apt update
sudo apt upgrade

# install Apache 2
sudo apt install -y apache2
sudo ufw allow in "Apache Full"

# install MySQL
sudo apt install -y mysql-server

# install expect to simulate shell interactive session with user
sudo apt install -y expect

# secure MySQL
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn sudo mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
send \"0\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

# uninstall expect
sudo apt purge -y expect

# create database for Joomla
sudo mysql -e "CREATE DATABASE $JOOMLA_DATABASE DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -e "GRANT ALL ON $JOOMLA_DATABASE.* TO '$JOOMLA_USER_NAME'@'localhost' IDENTIFIED BY '$JOOMLA_USER_PASSWORD';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"

# install PHP and related dependencies
sudo apt install -y php php-cli libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

# restart Apache 2
sudo service apache2 restart

# download specified Joomla version in the main Apache 2 folder (we're not using vitual hosts here), uncompress it, configure and restart Apache 2
cd /var/www/html
sudo mv index.html index.html.bk
sudo wget "https://downloads.joomla.org/cms/joomla3/$JOOMLA_VERSION/Joomla_$JOOMLA_VERSION-Stable-Full_Package.zip"
sudo apt install -y zip unzip
sudo unzip "Joomla_$JOOMLA_VERSION-Stable-Full_Package.zip"
sudo a2enmod rewrite
sudo service apache2 restart
sudo chown -R www-data:www-data /var/www/
