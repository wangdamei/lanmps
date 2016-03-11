#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
IN_PWD=$(pwd)
IN_DOWN=${IN_PWD}/down
LOGPATH=${IN_PWD}/logs
IN_DIR="/Users/${USER}/lanmps"
IN_WEB_DIR=${IN_PWD}"/wwwroot"
IN_WEB_LOG_DIR=${IN_PWD}"/wwwLogs"

mkdir -p $IN_DIR/vhost
mkdir -p $IN_WEB_DIR
mkdir -p $IN_WEB_LOG_DIR


ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/php

brew update

#========================
#PHP
sudo mv /usr/bin/php /usr/bin/php55
sudo mv /usr/bin/php-config /usr/bin/php-config55
sudo mv /usr/bin/phpize /usr/bin/phpize55

brew install php56 \
--without-snmp \
--without-apache \
--with-debug \
--with-fpm \
--with-intl \
--with-homebrew-curl \
--with-homebrew-libxslt \
--with-homebrew-openssl \
--with-imap \
--with-mysql \
--with-tidy

brew install php56-pdo-dblib \
php56-pdo-pgsql \
php56-mcrypt \
php56-memcache \
php56-memcached \
php56-mongo \
php56-redis \
php56-xdebug \
php56-wbxml \
php56-opcache \
php56-pcntl \
php56-libevent \
#php56-xcache \
#php56-gearman \
#php56-http \
php56-msgpack


#========================
#nginx
brew install nginx

sudo chown root:wheel /usr/local/Cellar/nginx/1.8.1/bin/nginx
sudo chmod u+s /usr/local/Cellar/nginx/1.8.1/bin/nginx

mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.old

cd $IN_PWD
sudo cp -rf nginx.conf /usr/local/etc/nginx/

cp -rf conf.default.conf $IN_DIR/vhost/default.conf
cp -rf conf.upstream.conf $IN_DIR/vhost/upstream.conf
cp -rf action.nginx $IN_DIR/nginx

chmod +x $IN_DIR/nginx
ln -s /usr/local/sbin/php56-fpm $IN_DIR/php56-fpm