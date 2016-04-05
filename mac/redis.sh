#!/bin/bash 
# 
# Init file for redis 
# 
# chkconfig: - 80 12 
# description: redis daemon 
# 
# processname: redis 
# config: /etc/redis.conf 
# pidfile: /var/run/redis.pid 
#source /etc/init.d/functions 
#BIN="/usr/local/bin" 
BIN="/usr/local/Cellar/redis/3.0.7/bin" 
CONFIG="/usr/local/etc/redis.conf" 
PIDFILE="/usr/local/var/run/redis.pid" 
### Read configuration 
[ -r "$SYSCONFIG" ] && source "$SYSCONFIG" 
RETVAL=0 
prog="redis-server" 
desc="Redis Server" 
start() { 
        echo $"Starting $desc: " 
        nohup $BIN/$prog $CONFIG &
        RETVAL=$? 
        return $RETVAL 
} 
stop() { 
        echo  $"Stop $desc: " 
        kill -9 `cat $PIDFILE`
        RETVAL=$? 
        rm -rf $PIDFILE
        return $RETVAL 
} 
restart() { 
        stop 
        start 
} 
case "$1" in 
  start) 
        start 
        ;; 
  stop) 
        stop 
        ;; 
  restart) 
        restart 
        ;; 
  condrestart) 
        restart 
        RETVAL=$? 
        ;; 
  status) 
        if [ -f $PIDFILE ]; then
            echo "$desc is runing!"
        else
            echo "$desc is stop!"
        fi
        RETVAL=$? 
        ;; 
   *) 
        echo $"Usage: $0 {start|stop|restart|condrestart|status}" 
        RETVAL=1 
esac 
exit $RETVAL