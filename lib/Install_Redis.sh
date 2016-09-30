function Install_Redis()
{
	echo "=========================== install Redis ======================"
	echo "=========================== install Redis ======================"
	echo "=========================== install Redis ======================"
	local IN_LOG=$LOGPATH/install_Install_Redis.sh.lock
	echo
    [ -f "$IN_LOG" ] && return

    REDIS_PATH=${IN_DIR}/redis
    mkdir -p $REDIS_PATH

    cd $IN_DOWN
    tar zxvf redis-${VERS['redis']}.tar.gz
    cd redis-${VERS['redis']}
    make prefix=$REDIS_PATH

    cp -rf src/redis-server  $REDIS_PATH
    cp -rf src/redis-benchmark $REDIS_PATH
    cp -rf src/redis-cli  $REDIS_PATH
    cp -rf src/redis-check-aof  $REDIS_PATH
    cp -rf src/redis-check-rdb  $REDIS_PATH
    cp -rf redis.conf  $REDIS_PATH
    cp -rf utils/redis_init_script ${IN_DIR}/bin/redis

    if [ -e /usr/local/bin/redis-server ]; then
        echo ""
    else
        ln -s "${REDIS_PATH}/redis-server" /usr/local/bin/redis-server
        ln -s "${REDIS_PATH}/redis-cli" /usr/local/bin/redis-cli
    fi

    sed -i "s#/etc/redis/\${REDISPORT}.conf#${REDIS_PATH}/redis.conf#g" ${IN_DIR}/bin/redis

	touch $IN_LOG
	echo "=========================== install Redis End======================"
	echo "=========================== install Redis End======================"
	echo "=========================== install Redis End======================"
}