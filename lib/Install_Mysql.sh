# mysql install function
function Install_Mysql {
	local IN_LOG=$LOGPATH/install_Install_Mysql.sh.lock
	echo
    [ -f "$IN_LOG" ] && return
	
    echo "============================Install MySQL ${MYSQL_KEY}=================================="
	
	echo "Input $MYSQL_SELECT"
	echo "Install $MYSQL_ID ${MYSQL_KEY} "


	if [ $MYSQL_ID == "mysql" ]; then
	    echo "${IN_PWD}/lib/Install_Mysql_${MYSQL_KEY}.sh"

    	import "${IN_PWD}/lib/Install_Mysql_${MYSQL_KEY}.sh"
    else
        echo "${IN_PWD}/lib/Install_Mysql_MariaDB_${MYSQL_KEY}.sh"

        import "${IN_PWD}/lib/Install_Mysql_MariaDB_${MYSQL_KEY}.sh"
    fi
	echo "============================MySQL ${MYSQL_KEY} install completed========================="
	touch $IN_LOG
}
