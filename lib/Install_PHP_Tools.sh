function Install_PHP_Tools()
{
    # $1 第一个参数为 PHP安装后路径
    PHP_PATH=$1
    echo "PHP_PATH = ${PHP_PATH}"
	local php_ini=$PHP_PATH/php.ini
	echo "================================="
    echo "================================="
    echo "================================="
	echo "Install memcache php extension..."
	
	echo "tar zxvf memcache-${VERS['php-memcache']}.tgz"
	cd $IN_DOWN
	tar zxvf memcache-${VERS['php-memcache']}.tgz
	cd memcache-${VERS['php-memcache']}
	${PHP_PATH}/bin/phpize
	./configure --enable-memcache --with-php-config=${PHP_PATH}/bin/php-config --with-zlib-dir
	make && make install

	echo "================================="
	echo "================================="
	echo "================================="
	echo "Install Redis php extension..."
    echo "tar zxvf redis-${VERS['php-redis']}.tgz"
    cd $IN_DOWN

    if [ $PHP_KEY == "php7.0.x" ]; then
        tar zxvf redis-${VERS['php-redis']}.tgz
        cd redis-${VERS['php-redis']}
    else
        tar zxvf redis-${VERS['php-redis2.x']}.tgz
        cd redis-${VERS['php-redis2.x']}
    fi

    make distclean
	${PHP_PATH}/bin/phpize
	./configure --with-php-config=${PHP_PATH}/bin/php-config
    make && make install
	echo "================================="
	echo "================================="
	echo "================================="
    echo "install php_fileinfo "
	echo "install php_fileinfo "
	cd ${PHP_PATH}/ext/fileinfo
	${PHP_PATH}/bin/phpize
	./configure --with-php-config=${PHP_PATH}/bin/php-config
	make && make install

	echo "================================="
    echo "================================="
    echo "================================="
    echo "install intl "
    echo "install intl "
    cd ${PHP_PATH}/ext/intl
    ${PHP_PATH}/bin/phpize
    ./configure --with-php-config=${PHP_PATH}/bin/php-config
    make && make install

    echo "================================="
    echo "================================="
    echo "================================="
    echo "install phar "
    echo "install phar "
    cd ${PHP_PATH}/ext/phar
    ${PHP_PATH}/bin/phpize
    ./configure --with-php-config=${PHP_PATH}/bin/php-config
    make && make install

    echo "================================="
    echo "================================="
    echo "================================="

	local php_v=`${PHP_PATH}/bin/php -v`
	local php_ext_date="20131226"
	local PHP_EXT='\nextension = "memcache.so"\nextension = "redis.so"\nextension=fileinfo.so\nextension=intl.so\nextension=phar.so\n'
	sed -i 's#; extension_dir = "./"#extension_dir = "./"#' $php_ini
	echo "${PHP_PATH}/bin/php -v"
	echo $php_v
	if echo "$php_v" | grep -q "7.0."; then
    		php_ext_date="20151012"
    		PHP_EXT='\nextension = "redis.so"\n'
	elif echo "$php_v" | grep -q "5.6."; then
		php_ext_date="20131226"
	elif echo "$php_v" | grep -q "5.5."; then
		php_ext_date="20121212"
	elif echo "$php_v" | grep -q "5.4."; then
		php_ext_date="20100525"
	elif echo "$php_v" | grep -q "5.3."; then
		php_ext_date="20090626"
	elif echo "$php_v" | grep -q "5.2."; then
		php_ext_date="20060613"
	fi
	if [ "$php_ext_date" == "20090626" ]; then
	    php_ext_date="no-debug-zts-${php_ext_date}"
	elif [ "$php_ext_date" == "20100525" ]; then
	    php_ext_date="no-debug-zts-${php_ext_date}"
	else
	    php_ext_date="no-debug-non-zts-${php_ext_date}"
	fi

	EXTENSION_DIR=${PHP_PATH}/lib/php/extensions/${php_ext_date}
	sed -i "s#extension_dir = \"./\"#extension_dir=${EXTENSION_DIR}${PHP_EXT}#" $php_ini
	echo 's#extension_dir = "./"#extension_dir = '${EXTENSION_DIR}${PHP_EXT}'#'
	
	echo "Install xdebug php extension..."
	cd $IN_DOWN
	tar zxvf xdebug-${VERS['php-xdebug']}.tgz
	cd xdebug-${VERS['php-xdebug']}
	${PHP_PATH}/bin/phpize
	./configure --enable-xdebug --with-php-config=${PHP_PATH}/bin/php-config
	make && make install
	echo '
[Xdebug]
;zend_extension="'$PHP_PATH'/lib/php/extensions/no-debug-zts-'$php_ext_date'/xdebug.so"
;xdebug.auto_trace=1
;xdebug.collect_params=1
;xdebug.collect_return=1
;xdebug.trace_output_dir = "'$IN_WEB_LOG_DIR'"
;xdebug.profiler_enable=1
;xdebug.profiler_output_dir = "'$IN_WEB_LOG_DIR'" 
;xdebug.max_nesting_level=10000
;xdebug.remote_enable=1
;xdebug.remote_autostart = 0
;xdebug.remote_host=localhost
;xdebug.remote_port=9033
;xdebug.remote_handler=dbgp
;xdebug.idekey="PHPSTORM"  
' >> $php_ini
	
	echo "Create PHP Info Tool..."
	#TOOLS
	cd $IN_PWD
	cp conf/index.html $IN_WEB_DIR/default/index.html
	cp conf/php.tz.php $IN_WEB_DIR/default/_tz.php
	cat > $IN_WEB_DIR/default/_phpinfo.php<<EOF
<?php
phpinfo();
?>
EOF
        echo "==================================="
        echo "==================================="
        echo "==================================="
        cd $IN_DOWN
        echo "安装 composer "
        php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php

        php composer-setup.php

        php -r "unlink('composer-setup.php');"

        mv composer.phar /usr/local/bin/composer
}
