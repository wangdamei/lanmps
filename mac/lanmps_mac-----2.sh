#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
IN_PWD=$(pwd)
IN_DOWN=${IN_PWD}/down
LOGPATH=${IN_PWD}/logs
IN_DIR=${IN_PWD}"/lanmps"
IN_WEB_DIR=${IN_PWD}"/wwwroot"
IN_WEB_LOG_DIR=${IN_PWD}"/wwwLogs"

mkdir -p $IN_DIR


declare -A DPF;
#http://cn2.php.net/distributions/php-5.6.19.tar.gz
DPF['php5.6.x']="http://cn2.php.net/distributions/php-5.6.19.tar.gz"
DPF['php5.6.x-V']="5.6.19"

PHP_URL="http://cn2.php.net/distributions/php-5.6.19.tar.gz"

#ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz
#https://sourceforge.net/projects/pcre/files/pcre/
DPF['pcre']="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz"
DPF['pcre-V']="8.38"


if [ -s $PHP_URL ]; then
    echo "php [found]"
else
    echo "Error: $IN_DOWN/$2 not found!!!download now......"
    wget_down ${DUS[$t_name]}
fi


tar -xvf pcre-{$DPF['pcre-V']}.tar.gz

./configure

make

make install


groupadd www
useradd -s /sbin/nologin -g www www


tar zxvf php-${DPF['php5.6.x-V']}.tar.gz
cd php-${DPF['php5.6.x-V']}/

./configure --prefix="/Users/fox/lanmps/php" \
--with-config-file-path="/Users/fox/lanmps/php" \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--enable-opcache \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo --enable-fpm --with-fpm-user=www --with-fpm-group=www

#make ZEND_EXTRA_LIBS='-liconv'
make
make install
--with-openssl \



Init_SetDirectoryAndUser 2>&1 | tee -a "${LOGPATH}/1.Init_SetDirectoryAndUser-install.log"

Init 2>&1 | tee -a "${LOGPATH}/2.Init-install.log"

{ 
 
Init_CheckAndDownloadFiles;

Install_DependsAndOpt;

if [ $SERVER == "apache" ]; then
	Install_Apache;
else
	Install_Nginx;
fi

Install_PHP;

Install_PHP_Tools;

Install_Memcached;

Install_Mysql;

Install_Sphinx;

 }  2>&1 | tee -a "${LOGPATH}/3.Install.log"

Starup 2>&1 | tee -a "${LOGPATH}/9.Starup-install.log"

CheckInstall 2>&1 | tee -a "${LOGPATH}/10.CheckInstall-install.log"


http://php-osx.liip.ch/