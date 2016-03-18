#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
IN_PWD=$(pwd)
IN_DOWN=${IN_PWD}/down
IN_DIR=~/lanmps
IN_USER_DIR=~
IN_USER=${IN_USER_DIR##*/}
IN_WEB_DIR=${IN_DIR}/wwwroot
IN_WEB_LOG_DIR=${IN_DIR}/wwwLogs

mkdir -p $IN_DIR/vhost
mkdir -p $IN_WEB_DIR
mkdir -p $IN_WEB_LOG_DIR





mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.old

cd $IN_PWD
sudo cp -rf conf.nginx.conf /usr/local/etc/nginx/nginx.conf

#cp -rf conf.default.conf $IN_DIR/vhost/default.conf
cp -rf conf.upstream.conf $IN_DIR/vhost/upstream.conf
cp -rf action.nginx $IN_DIR/nginx

chmod +x $IN_DIR/nginx



php_ini="/usr/local/etc/php/5.6/php.ini"
rm -rf /private/etc/php.ini
ln -s $php_ini /private/etc/php.ini
cp $php_ini "${php_ini}.old"


sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $php_ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' $php_ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' $php_ini
#sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' $php_ini
#sed -i 's:mysql.default_socket =:mysql.default_socket ='$IN_DIR'/mysql/data/mysql.sock:g' $php_ini
#sed -i 's:pdo_mysql.default_socket.*:pdo_mysql.default_socket ='$IN_DIR'/mysql/data/mysql.sock:g' $php_ini
sed -i 's/expose_php = On/expose_php = Off/g' $php_ini

#sed -i 's#\[opcache\]#\[opcache\]\nzend_extension=opcache.so#g' $php_ini
sed -i 's/;opcache.enable=0/opcache.enable=0/g' $php_ini
#sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' $php_ini
#sed -i 's/;opcache.memory_consumption=64/opcache.memory_consumption=128/g' $php_ini
#sed -i 's/;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=8/g' $php_ini
#sed -i 's/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=4000/g' $php_ini
#sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g' $php_ini
#sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/g' $php_ini
#sed -i 's/;opcache.save_comments=1/opcache.save_comments=0/g' $php_ini

ln -s /usr/local/sbin/php56-fpm $IN_DIR/php-fpm

conf=/usr/local/etc/php/5.6/php-fpm.conf
cp -rf $conf "${conf}.old"
rm -rf /private/etc/php-fpm.conf
ln -s $conf /private/etc/php-fpm.conf

#sed -i 's:;pid = run/php-fpm.pid:pid = run/php-fpm.pid:g' $conf
sed -i 's:;error_log = log/php-fpm.log:error_log = '"$IN_WEB_LOG_DIR"'/php-fpm.log:g' $conf
sed -i 's:;log_level = notice:log_level = notice:g' $conf
sed -i 's:pm.max_children = 5:pm.max_children = 10:g' $conf
sed -i 's:pm.max_spare_servers = 3:pm.max_spare_servers = 6:g' $conf
sed -i 's:;request_terminate_timeout = 0:request_terminate_timeout = 100:g' $conf
sed -i 's/127.0.0.1:9000/127.0.0.1:9950/g' $conf


if [ -s "${THIS_PATH}/.bashrc" ]; then
    echo " .bashrc FIND "
else
    cd $IN_PWD
    cp -rf .bashrc ~/.bashrc
fi

if [ -s "/Users/${USER}/.bash_profile" ]; then
    echo " .bash_profile FIND "
else
    cd $IN_PWD
    cp -rf .bashrc ~/.bash_profile
fi


chown -R $IN_USER:staff $IN_DIR
echo "OK"