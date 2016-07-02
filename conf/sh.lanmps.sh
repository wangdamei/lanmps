#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi

PS_SERVER=`ps ax | grep nginx.conf | grep -v "grep"`
if [[ $PS_SERVER ]];then
	SERVER="nginx"
else
	SERVER="apache"
fi

IN_DIR="/www/lanmps"
echo "========================================================================="
echo "Manager for LANMPS V2.2.1 "
echo "========================================================================="
echo "LANMPS is a tool to auto-compile & install Apache+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to Manage status of lanmps "
echo "For more information please visit http://www.lanmps.com "
echo ""
echo "   Usage: /root/lanmps {start|stop|reload|restart|kill|status}"
echo "or Usage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
echo "========================================================================="

function_start()
{
    echo "Starting LANMPS..."
	
	if [[ $SERVER == "apache" ]];then
	    $IN_DIR/bin/httpd start
	else
	    $IN_DIR/bin/nginx start
		$IN_DIR/bin/php-fpm start
	fi
    
    $IN_DIR/bin/mysql start
	
	$IN_DIR/bin/memcached start
}

function_stop()
{
    echo "Stoping LANMPS..."
	
	if [[ $SERVER == "apache" ]];then
	    $IN_DIR/bin/httpd stop
	else
	    $IN_DIR/bin/nginx stop
		$IN_DIR/bin/php-fpm stop
	fi

    $IN_DIR/bin/mysql stop
	
	$IN_DIR/bin/memcached stop
}

function_reload()
{
    echo "Reload LANMPS..."
	
	if [[ $SERVER == "apache" ]];then
	    $IN_DIR/bin/httpd reload
	else
	    $IN_DIR/bin/nginx reload
		$IN_DIR/bin/php-fpm reload
	fi

    $IN_DIR/bin/mysql reload
}

function_kill()
{
    if [[ $SERVER == "apache" ]];then
	     killall httpd
	else
	    killall nginx
		killall php-cgi
		killall php-fpm
	fi
    killall mysqld
	killall memcached
}

function_status()
{

    if [[ $SERVER == "apache" ]];then
	    $IN_DIR/bin/httpd status
	else
	    $IN_DIR/bin/nginx status
		$IN_DIR/bin/php-fpm status
	fi

	$IN_DIR/bin/mysql status
}

case "$1" in
	start)
		function_start
		;;
	stop)
		function_stop
		;;
	restart)
		function_stop
		function_start
		;;
	reload)
		function_reload
		;;
	kill)
		function_kill
		;;
	status)
		function_status
		;;
	*)
esac
echo "Usage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
exit
