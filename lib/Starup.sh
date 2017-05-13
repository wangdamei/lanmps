# start services
function Starup()
{
    #设置默认目录权限
    chown -R www:www $IN_WEB_DIR/default
	cd $IN_PWD

	echo "============================add nginx and php-fpm on startup============================"
	echo "Set start"
	systemd_path=/lib/systemd/system
	if [ ! -d "$systemd_path" ]; then
		if [ $OS_RL = "centos" ]; then
			if [ $SERVER == "nginx" ]; then
				chkconfig --add php-fpm
				chkconfig --level 345 php-fpm on
				
				chkconfig --add nginx
				chkconfig --level 345 nginx on
			else
				chkconfig --add httpd
				chkconfig --level 345 httpd on
			fi
			chkconfig --add mysql
			chkconfig --level 345 mysql on
			
			chkconfig --add memcached
			chkconfig --level 345 memcached on
		else
			if [ $SERVER == "apache" ]; then
				update-rc.d -f httpd defaults
			else
				update-rc.d -f php-fpm defaults
				update-rc.d -f nginx defaults
			fi
			update-rc.d -f mysql defaults
			update-rc.d -f memcached defaults
		fi
	else
	    if [ ! $IN_DIR = "/www/lanmps" ]; then
            sed -i "s:/www/lanmps:$IN_DIR:g" $IN_PWD/conf/service.nginx.service
            sed -i "s:/www/lanmps:$IN_DIR:g" $IN_PWD/conf/service.php-fpm.service
            sed -i "s:/www/lanmps:$IN_DIR:g" $IN_PWD/conf/service.mysql.service
            sed -i "s:/www/lanmps:$IN_DIR:g" $IN_PWD/conf/service.memcached.service
        fi

		file_cp $IN_PWD/conf/service.nginx.service "${systemd_path}/nginx.service"
		file_cp $IN_PWD/conf/service.php-fpm.service "${systemd_path}/php-fpm.service"
		file_cp $IN_PWD/conf/service.mysql.service "${systemd_path}/mysql.service"
		#file_cp $IN_PWD/conf/service.memcached.service "${systemd_path}/memcached.service"
		file_cp $IN_PWD/conf/service.redis.service "${systemd_path}/redis.service"
		
		systemctl enable nginx.service
		systemctl enable php-fpm.service
		systemctl enable mysql.service
		systemctl enable redis.service
		#关闭不启动
		#systemctl enable memcached.service
		
		
		#systemctl start nginx.service
		#systemctl start php-fpm.service
		#systemctl start mysql.service
		#systemctl start redis.service
		#关闭不启动
		#systemctl start memcached.service
	fi
	
	echo "===========================add nginx and php-fpm on startup completed===================="

	
	echo "Starting LANMPS..."
	if [ ! -d "$systemd_path" ]; then
	    echo " old system starting "
		$IN_DIR/bin/mysql start
		
		if [ $SERVER == "nginx" ]; then
			$IN_DIR/bin/php-fpm${PHP_VER_NUM} start
			$IN_DIR/bin/nginx start
		else
			$IN_DIR/bin/httpd start
		fi
		#关闭不启动
		#$IN_DIR/bin/memcached start
	else
	    echo " new system starting"
	    echo " systemctl start xxxxx "

		systemctl start nginx.service
		systemctl start php-fpm.service
		systemctl start mysql.service
		systemctl start redis.service
		#关闭不启动
		#systemctl start memcached.service
	fi
	#add 80 port to iptables
	if [ -s /sbin/iptables ]; then
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
		/sbin/iptables -I INPUT -p tcp --dport 22 -j ACCEPT
		iptables-save > /etc/iptables.up.rules
		iptables-save > /etc/network/iptables.up.rules
		#/etc/rc.d/bin/iptables save
		#/etc/bin/iptables restart
	fi
	if [ -d "$systemd_path" ]; then
	    firewall-cmd --zone=public --add-port=80/tcp --permanent
	fi
}

function CheckInstall()
{
	echo "===================================== Check install ==================================="
	clear
	isnginx=""
	ismysql=""
	isphp=""
	echo "Checking..."
	if [ $SERVER == "nginx" ]; then
		if [ -s $IN_DIR/nginx ] && [ -s $IN_DIR/nginx/sbin/nginx ]; then
			echo "${SERVER}: OK"
			isnginx="ok"
		else
			echo "Error: $IN_DIR/${SERVER} not found!!!${SERVER} install failed."
		fi
		
		if [ -s "$IN_DIR/php/sbin/php-fpm" ] && [ -s "$IN_DIR/php/php.ini" ] && [ -s $IN_DIR/php/bin/php ]; then
			echo "PHP: OK"
			echo "PHP-FPM: OK"
			isphp="ok"
		else
			echo "Error: $IN_DIR/php not found!!!PHP install failed."
		fi
	else
		if [ -s $IN_DIR/apache ] && [ -s $IN_DIR/apache/bin/httpd ]; then
			echo "${SERVER}: OK"
			isnginx="ok"
		else
			echo "Error: $IN_DIR/${SERVER} not found!!!${SERVER} install failed."
		fi
		
		if [ -s "$IN_DIR/php/php.ini" ] && [ -s $IN_DIR/php/bin/php ]; then
			echo "PHP: OK"
			isphp="ok"
		else
			echo "Error: $IN_DIR/php not found!!!PHP install failed."
		fi
	fi
	
	if [ -s "$IN_DIR/mysql" ] && [ -s "$IN_DIR/mysql/bin/mysql" ]; then
		  echo "MySQL: OK"
		  ismysql="ok"
		else
		  echo "Error: $IN_DIR/mysql not found!!!MySQL install failed."
		fi
	
	if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
		echo "========================================================================="
		echo "${PROGRAM_NAME} ${PROGRAM_VERSION} for CentOS/Ubuntu Linux Written by Licess "
		echo "========================================================================="
		echo ""
		echo "For more information please visit http://www.lanmps.com"
		echo ""
		echo "lanmps bin status manage: $IN_DIR/bin/* "
		echo "default mysql root password:$MysqlPassWord"
		echo "Prober : http://$IP/_tz.php"
		echo "phpinfo : http://$IP/_phpinfo.php"
		echo "phpMyAdmin : http://$IP/_phpmyadmin/"
		echo "Add VirtualHost : $IN_DIR/vhost.sh"
		echo ""
		echo "The path of some dirs:"
		echo "mysql dir:   $IN_DIR/$MYSQL_INITD"
		echo "php dir:     $IN_DIR/php"
		if [ $SERVER == "nginx" ]; then
			echo "nginx dir:   $IN_DIR/nginx"
		else
			echo "apache dir:   $IN_DIR/apache"
		fi
		echo "web dir :    $IN_WEB_DIR/default"
		echo ""
		echo "========================================================================="
		#$IN_DIR/lanmps status
		ss -pltn

		if [ $MYSQL_SELECT == "2" ]; then
        	   echo "MySql 5.7.X版本 默认密码为空字符串"
        fi
	else
		echo "Sorry,Failed to install LANMPS!"
		echo "Please visit https://github.com/foxiswho/lanmps/issues feedback errors and logs."
		echo "You can download $LOGPATH from your server,And upload all the files in the directory to the Forum."
	fi
}
