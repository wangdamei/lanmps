function Install_Redis()
{
	echo "=========================== install Redis ======================"
	echo "=========================== install Redis ======================"
	echo "=========================== install Redis ======================"
	local IN_LOG=$LOGPATH/install_Install_Redis.sh.lock
	echo
    [ -f "$IN_LOG" ] && return

	touch $IN_LOG
	echo "=========================== install Redis End======================"
	echo "=========================== install Redis End======================"
	echo "=========================== install Redis End======================"
}