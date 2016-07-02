# mariadb install function

    MYSQL_PATH=$IN_DIR/mariadb${VERS['MariaDB']}
    echo "============================Install MariaDB ${VERS['MariaDB']}=================================="
	echo "Delete the old configuration files and directory   /etc/my.cnf /etc/mysql/my.cnf /etc/mysql/"
	
	cd $IN_DOWN
	tar zxvf mariadb-${VERS['MariaDB']}.tar.gz
	cd mariadb-${VERS['MariaDB']}/
	cmake . \
	-DCMAKE_INSTALL_PREFIX=$MYSQL_PATH \
	-DMYSQL_DATADIR=$MYSQL_PATH/data \
	-DSYSCONFDIR=$MYSQL_PATH \
	-DMYSQL_UNIX_ADDR=$MYSQL_PATH/data/mysql.sock \
	-DMYSQL_TCP_PORT=3306 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_MEMORY_STORAGE_ENGINE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DEXTRA_CHARSETS=all \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_READLINE=1 \
	-DWITH_SSL=system \
	-DWITH_ZLIB=system \
	-DMYSQL_USER=mysql \
	-DWITH_EMBEDDED_SERVER=1 \
	-DENABLED_LOCAL_INFILE=1
	make && make install

	local cnf=$MYSQL_PATH/my.cnf
	cp $IN_PWD/conf/conf.mariadb.conf $cnf
	if [ ! $IN_DIR = "/www/lanmps" ]; then
		sed -i "s:/www/lanmps:$IN_DIR:g" $cnf
	fi
	
	sed -i 's:#loose-skip-innodb:loose-skip-innodb:g' $cnf

	$MYSQL_PATH/scripts/mysql_install_db --defaults-file=$cnf --basedir=$MYSQL_PATH --datadir=$MYSQL_PATH/data --user=mysql
	chown -R mysql $MYSQL_PATH/data
	chgrp -R mysql $MYSQL_PATH/.
	
	cp support-files/mysql.server $IN_DIR/bin/mysql
	chmod 755 $IN_DIR/bin/mysql
	if [ ! $IN_DIR = "/www/lanmps" ]; then
		sed -i "s:/www/lanmps:$IN_DIR:g" $IN_DIR/bin/mysql
	fi

	cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${MYSQL_PATH}/lib
/usr/local/lib
EOF

	ldconfig
	
	#start
	$IN_DIR/bin/mysql start
	


	$MYSQL_PATH/bin/mysqladmin -u root password $MysqlPassWord

	cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$MysqlPassWord') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

	$MYSQL_PATH/bin/mysql -u root -p$MysqlPassWord -h localhost < /tmp/mysql_sec_script

	rm -f /tmp/mysql_sec_script
	
	mkdir -p /var/log/mysqld
	ln -s $MYSQL_PATH/data/mysql.sock /var/log/mysqld/mysql.sock
	
	$IN_DIR/bin/mysql restart
	$IN_DIR/bin/mysql stop

    ln -s $MYSQL_PATH/lib/mysql /usr/lib/mysql
	ln -s $MYSQL_PATH/include/mysql /usr/include/mysql
	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi

    ln -s $MYSQL_PATH/bin/mysql /usr/bin/mariadb
    ln -s $MYSQL_PATH/bin/mysqldump /usr/bin/mariadbdump
	if [ -e /usr/bin/mysql ]; then

    else
        	ln -s $MYSQL_PATH/bin/mysql /usr/bin/mysql
        	ln -s $MYSQL_PATH/bin/mysqldump /usr/bin/mysqldump
    fi

if [ ! -d "$IN_DIR/mysql" ]; then
        ln -s $MYSQL_PATH $IN_DIR/mysql
fi

