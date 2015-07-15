#!/usr/bin/env bash

# Update
# --------------------
apt-get update


# Install Apache & PHP
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc


# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
rm -rf /var/www

if [ ! -d "/vagrant/httpdocs" ]; then
  mkdir /vagrant/httpdocs
fi

ln -fs /vagrant/httpdocs /var/www


# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
<VirtualHost *:80>

  DocumentRoot "/var/www"
  ServerName simple-magento-vagrant.dev

  <Directory "/var/www">
    AllowOverride All
  </Directory>

  SetEnv MAGE_IS_DEVELOPER_MODE true

</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default

a2enmod rewrite
service apache2 restart


# Adminer
# --------------------
if [ ! -d "/vagrant/httpdocs/adminer" ]; then
  echo "Adminer not found at /vagrant/httpdocs/adminer and will be installed..."

  mkdir /vagrant/httpdocs/adminer
  wget -O /vagrant/httpdocs/adminer/index.php http://downloads.sourceforge.net/adminer/adminer-4.0.3.php

  echo "Adminer installed... Use http://simple-magento-vagrant.dev/adminer/ URL to use it."
fi


# Mysql
# --------------------
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive

# Install MySQL quietly
apt-get -q -y install mysql-server-5.5

mysql -u root -e "DROP DATABASE IF EXISTS magentodb"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS magentodb"
mysql -u root -e "GRANT ALL PRIVILEGES ON magentodb.* TO 'magentouser'@'localhost' IDENTIFIED BY 'password'"
mysql -u root -e "FLUSH PRIVILEGES"


# Magento
# --------------------

#
# Unpack magento
# --------------------
if [ -f "/vagrant/source/magento-1.8.1.0.tar.bz2" ]; then
  echo "/vagrant/source/magento-1.8.1.0.tar.bz2 found. Start copy..."
  tar xvf /vagrant/source/magento-1.8.1.0.tar.bz2 -C /vagrant/httpdocs/ --exclude='._*'

  echo "moving files to /vagrant/httpdocs folder..."
  mv /vagrant/httpdocs/magento/{*,.*} /vagrant/httpdocs

  rm -r /vagrant/httpdocs/magento/

  echo "Done."
else
  echo "/vagrant/source/magento-1.8.1.0.tar.bz2 not found."
fi


#
# Import DB
# --------------------
if [ -f "/vagrant/source/sql_magento_sample_data_1.6.1.0.sql" ]; then

  echo "/vagrant/source/sql_magento_sample_data_1.6.1.0.sql found. Start import..."
  mysql -u root magentodb < /vagrant/source/sql_magento_sample_data_1.6.1.0.sql
  echo "Done. Run db update..."

  #
  # Update DB
  # --------------------
  mysql -u root -e "UPDATE magentodb.core_config_data SET value = 'http://simple-magento-vagrant.dev/' WHERE core_config_data.path = 'web/unsecure/base_url'"
  mysql -u root -e "UPDATE magentodb.core_config_data SET value = 'http://simple-magento-vagrant.dev/' WHERE core_config_data.path = 'web/secure/base_url'"

  echo "Update complete."
else
  echo "/vagrant/source/sql_magento_sample_data_1.6.1.0.sql not found."
fi


# Import Media
# --------------------
if [ -f "/vagrant/source/media_magento_sample_data_for_1.6.1.0.tar.gz" ]; then
  echo "/vagrant/source/media_magento_sample_data_for_1.6.1.0.tar.gz found. Start copy..."
  tar xvzf /vagrant/source/media_magento_sample_data_for_1.6.1.0.tar.gz -C /vagrant/httpdocs/ --exclude='._*'
  echo "Done."
else
  echo "/vagrant/source/media_magento_sample_data_for_1.6.1.0.tar.gz not found."
fi
