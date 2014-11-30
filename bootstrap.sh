#!/usr/bin/env bash

# author: @elliotwms

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- And phpMyAdmin too (lazybones) ---"
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'

echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties git-core ruby screen --force-yes

echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql phpmyadmin --force-yes

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug --force-yes

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

echo "--- Setting document root ---"
sudo rm -rf /var/www/html
sudo ln -fs /vagrant/public /var/www/html

echo "--- Setting SSH directory redirect ---"
printf "\n" >> /home/vagrant/.bashrc
printf "# Vagrant SSH redirect\n" >> /home/vagrant/.bashrc
printf "cd /vagrant\n" >> /home/vagrant/.bashrc

echo "--- Bash better history hack ---"
# https://coderwall.com/p/oqtj8w
touch /home/vagrant/.inputrc
cat << EOF | sudo tee -a /home/vagrant/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOF

echo "--- What developer codes without errors turned on? Not you, sensei. ---"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart

echo "--- Composer is the future. But you knew that, did you sensei? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

cd /vagrant

echo "--- Installing and updating Composer packages ---"
sudo composer install

echo "--- All set to go! ---"
