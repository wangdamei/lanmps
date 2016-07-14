# mysql install function
function Install_Mysql {
	local IN_LOG=$LOGPATH/install_Install_Mysql.sh.lock
	echo
    [ -f "$IN_LOG" ] && return
	
    echo "============================Install MySQL ${VERS['mysql']}=================================="
	
	echo "Input $MYSQL_SELECT"
	echo "Install $MYSQL_ID ${VERS[$MYSQL_ID]} "


	if [ $MYSQL_ID == "mysql" ]; then
	    echo "${IN_PWD}/lib/Install_Mysql_${MYSQL_VER}.sh"

    	import "${IN_PWD}/lib/Install_Mysql_${MYSQL_VER}.sh"
    else
        echo "${IN_PWD}/lib/Install_Mysql_MariaDB_${MYSQL_VER}.sh"

        import "${IN_PWD}/lib/Install_Mysql_MariaDB_${MYSQL_VER}.sh"
    fi
	echo "============================MySQL ${VERS['mysql']} install completed========================="
	touch $IN_LOG
}
