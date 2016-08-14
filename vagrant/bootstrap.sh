#!/usr/bin/env bash


echo "=================================================="
echo "Aloha! Now we will try to Install Ubuntu 14.04 LTS"
echo "with Apache 2.4, PHP 5.6, MySQL 5.6(manual)"
echo "and others dependencies needed for Magento 1(2)."
echo "Good luck :P"
echo "=================================================="
echo ""
echo ""
echo "=================================================="
echo "SET LOCALES"
echo "=================================================="

export DEBIAN_FRONTEND=noninteractive

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales


echo "=================================================="
echo "RUN UPDATE"
echo "=================================================="

apt-get update
apt-get upgrade


echo "=================================================="
echo "INSTALLING APACHE"
echo "=================================================="

apt-get -y install apache2

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/httpdocs /var/www
fi

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
echo "$VHOST" > /etc/apache2/sites-available/000-default.conf

echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/localhost.conf

a2enconf localhost
a2enmod rewrite
service apache2 restart


echo "=================================================="
echo "INSTALLING PHP"
echo "=================================================="

apt-get -y update
apt-get -y install php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl

php5enmod mcrypt
service apache2 reload


echo "=================================================="
echo "INSTALLING and CONFIGURE NTP"
echo "=================================================="
apt-get -y install ntp



echo "=================================================="
echo "INSTALLING ADMINER"
echo "=================================================="
if [ ! -d "/vagrant/httpdocs/adminer" ]; then
  echo "Adminer not found at /vagrant/httpdocs/adminer and will be installed..."

  mkdir /vagrant/httpdocs/adminer
  wget -O /vagrant/httpdocs/adminer/index.php https://www.adminer.org/static/download/4.2.5/adminer-4.2.5.php

  echo "Adminer installed... Use http://simple-magento-vagrant.dev/adminer/ URL to use it."
fi


echo "=================================================="
echo "INSTALLING MYSQL"
echo "=================================================="
apt-get -q -y install mysql-server-5.5

echo "=================================================="
echo "INSTALLING MYSQL MAGENTO DATABASE"
echo "=================================================="

mysql -u root -e "DROP DATABASE IF EXISTS magento"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS magento"
mysql -u root -e "GRANT ALL PRIVILEGES ON magento.* TO 'magento'@'localhost' IDENTIFIED BY 'password'"
mysql -u root -e "FLUSH PRIVILEGES"


echo "=================================================="
echo "CLEANING..."
echo "=================================================="
apt-get -y autoremove
apt-get -y autoclean


echo "=================================================="
echo "DOWNLOAD MAGENTO SOURCE AND SAMPLE"
echo "=================================================="
echo "Start download Magento 1.9.2.3 and sample data save version..."
if [ ! -d /vagrant/source ]; then
   mkdir /vagrant/source
fi

if [ ! -f /vagrant/source/magento-1.9.2.3.tar.gz ]; then
   wget -c https://github.com/OpenMage/magento-mirror/archive/1.9.2.3.tar.gz -O /vagrant/source/magento-1.9.2.3.tar.gz
fi

if [ ! -f /vagrant/source/magento-sample-data-1.9.1.0.tar.gz ]; then
   wget -c http://mirror.gunah.eu/magento/sample-data/magento-sample-data-1.9.1.0.tar.gz -O /vagrant/source/magento-sample-data-1.9.1.0.tar.gz
fi
echo "done."

echo "Extract Magento and sample data to /vagrant/httpdocs ..."
tar zxvf /vagrant/source/magento-1.9.2.3.tar.gz -C /vagrant/httpdocs --strip-components=1
tar zxvf /vagrant/source/magento-sample-data-1.9.1.0.tar.gz -C /vagrant/httpdocs --strip-components=1
echo "done."

echo "Import Sample database..."
mysql -u root magento < /vagrant/httpdocs/magento_sample_data_for_1.9.1.0.sql
echo "done."

echo "Update DB config with local domain name..."
mysql -u root -e "UPDATE magento.core_config_data SET value = 'http://simple-magento-vagrant.dev/' WHERE core_config_data.path = 'web/unsecure/base_url'"
mysql -u root -e "UPDATE magento.core_config_data SET value = 'http://simple-magento-vagrant.dev/' WHERE core_config_data.path = 'web/secure/base_url'"
echo "done."a


echo "=================================================="
echo "============= INSTALLATION COMPLETE =============="
echo "=================================================="
