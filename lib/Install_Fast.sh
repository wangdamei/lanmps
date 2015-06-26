# Sphinx install function
function Install_Fast {
	echo "FAST=============="
	echo "FAST=============="
	echo "FAST=============="
	echo "FAST=============="
	$IN_PWD/www.tar.gz
	[ -d "/www" ] && mv /www /www_$(date +%Y%m%d%H);
	tar -zxvf www.tar.gz -C /

	#nginx
	ln -s $IN_DIR/nginx/sbin/nginx /usr/bin/nginx
	ln -s $IN_DIR/vhost.sh /root/vhost.sh
	
	#php
	[ -e /usr/bin/php ] && rm -f "/usr/bin/php"
	[ -e /usr/bin/phpize ] && rm -f "/usr/bin/phpize"
	[ -e /usr/bin/php-fpm ] && rm -f "/usr/bin/php-fpm"
	ln -s "${IN_DIR}/php/bin/php" /usr/bin/php
	ln -s "${IN_DIR}/php/bin/phpize" /usr/bin/phpize
	ln -s "${IN_DIR}/php/sbin/php-fpm" /usr/bin/php-fpm
	
	#memcache
	ProgramIsInstalled "libevent" "libevent-${VERS['libevent']}-stable.tar.gz"
	ProgramInstalled "libevent" "libevent-${VERS['libevent']}-stable.tar.gz" "--prefix=/usr/local/libevent" "libevent-${VERS['libevent']}-stable.tar.gz"
	echo "/usr/local/libevent/lib/" >> /etc/ld.so.conf
	ln -s /usr/local/libevent/lib/libevent-2.0.so.5  /lib/libevent-2.0.so.5
	ldconfig
	ln $IN_DIR/memcached/bin/memcached /usr/bin/memcached
	
	#mysql
	cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${TMP_TTT_MARIADB_PATH}/lib
/usr/local/lib
EOF
	ldconfig
	ln -s $IN_DIR/mysql/lib/mysql /usr/lib/mysql
	ln -s $IN_DIR/mysql/include/mysql /usr/include/mysql
	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	ln -s $IN_DIR/mysql/bin/mysql /usr/bin/mysql
	ln -s $IN_DIR/mysql/bin/mysqldump /usr/bin/mysqldump
	ln -s $IN_DIR/mysql/bin/myisamchk /usr/bin/myisamchk
	ln -s $IN_DIR/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
	mkdir -p /var/log/mysqld
	ln -s $IN_DIR/mysql/data/mysql.sock /var/log/mysqld/mysql.sock
	
	echo "FAST=============="
	echo "FAST=============="
	echo "FAST=============="
	echo "FAST=============="
}