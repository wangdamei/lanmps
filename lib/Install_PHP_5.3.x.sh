
PHP_PATH=${IN_DIR}/php${VERS['php5.3.x']}
cd $IN_DOWN
tmp_configure=""
if [ $SERVER == "apache" ]; then
    tmp_configure="--with-apxs2=${IN_DIR}/apache/bin/apxs"
else
	tmp_configure="--enable-fpm --with-fpm-user=www --with-fpm-group=www"
fi

tar zxvf php-${VERS['php5.3.x']}.tar.gz
cd php-${VERS['php5.3.x']}/
./configure \
--prefix=$PHP_PATH \
--with-config-file-path=$PHP_PATH \
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
--disable-rpath \
--enable-magic-quotes \
--enable-safe-mode \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo $tmp_configure

if [ $OS_RL = "centos" ]; then
    make
else
	make ZEND_EXTRA_LIBS='-liconv'
fi

make install

rm -rf "/usr/bin/php53"
rm -rf "/usr/bin/phpize53"
rm -rf "/usr/bin/php-fpm53"

ln -s "${PHP_PATH}/bin/php" /usr/bin/php53
ln -s "${PHP_PATH}/bin/phpize" /usr/bin/phpize53
ln -s "${PHP_PATH}/sbin/php-fpm" /usr/bin/php-fpm53

if [ -e /usr/bin/php ]; then

else
    ln -s "${PHP_PATH}/bin/php" /usr/bin/php
    ln -s "${PHP_PATH}/bin/phpize" /usr/bin/phpize
    ln -s "${PHP_PATH}/sbin/php-fpm" /usr/bin/php-fpm
fi



echo "Copy new php configure file."
php_ini="${PHP_PATH}/php.ini"

cp php.ini-production $php_ini

cd $cur_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $php_ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' $php_ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' $php_ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' $php_ini
sed -i 's:mysql.default_socket =:mysql.default_socket ='$IN_DIR'/mysql/data/mysql.sock:g' $php_ini
sed -i 's:pdo_mysql.default_socket.*:pdo_mysql.default_socket ='$IN_DIR'/mysql/data/mysql.sock:g' $php_ini
sed -i 's/expose_php = Off/expose_php = On/g' $php_ini
#PHP-FPM
if [ $SERVER == "nginx" ]; then

    echo "MV php-fpm.conf file"
    conf=${PHP_PATH}/etc/php-fpm.conf;
    mv ${PHP_PATH}/etc/php-fpm.conf.default $conf

    sed -i 's:;pid = run/php-fpm.pid:pid = run/php-fpm.pid:g' $conf
    sed -i 's:;error_log = log/php-fpm.log:error_log = '"$IN_WEB_LOG_DIR"'/php-fpm.log:g' $conf
    sed -i 's:;log_level = notice:log_level = notice:g' $conf
    sed -i 's:pm.max_children = 5:pm.max_children = 10:g' $conf
    sed -i 's:pm.max_spare_servers = 3:pm.max_spare_servers = 6:g' $conf
    sed -i 's:;request_terminate_timeout = 0:request_terminate_timeout = 100:g' $conf


    echo "ln -s ${PHP_PATH}/etc/php-fpm.conf $IN_DIR/etc/php-fpm.conf "
    echo "Copy php-fpm bin file......"
    echo "chmod +x ${IN_DIR}/bin/php-fpm-53"

    sed -i 's/127.0.0.1:9000/127.0.0.1:9950/g' $conf
    ln -s ${PHP_PATH}/etc/php-fpm.conf $IN_DIR/etc/php-fpm-53.conf
    cp "${IN_DOWN}/php-${VERS['php5.3.x']}/sapi/fpm/init.d.php-fpm" $IN_DIR/bin/php-fpm53
    chmod +x $IN_DIR/bin/php-fpm53

    if [ ! $IN_DIR = "/www/lanmps" ]; then
        sed -i "s:/www/lanmps:$IN_DIR:g" $IN_DIR/bin/php-fpm-53
    fi


fi
#PHP-FPM
unset php_ini conf

Install_PHP_Tools