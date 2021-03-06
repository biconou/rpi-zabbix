#!/bin/bash

export MYSQL_PASSWORD="zabbix123"

_file_marker="/var/lib/mysql/.mysql-configured"

if [ ! -f "$_file_marker" ]; then
    /etc/init.d/mysql start
    mysql -u root -p"MYSQL_PASSWORD" -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';" 
    mysql -u root -p"$MYSQL_PASSWORD" -e "create database zabbix charset utf8;"
    mysql -u root -p"$MYSQL_PASSWORD" -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
    mysql -u root -p"$MYSQL_PASSWORD" -e "flush privileges;"
    
    /etc/init.d/mysql restart
    
    echo "Importing Databases"    
    mysql -u root -p"$MYSQL_PASSWORD" zabbix < /root/schema.sql
    mysql -u root -p"$MYSQL_PASSWORD" zabbix < /root/images.sql
    mysql -u root -p"$MYSQL_PASSWORD" zabbix < /root/data.sql
    /etc/init.d/mysql stop
    touch "$_file_marker"    
fi

_cmd="/usr/bin/monit -d 10 -Ic /etc/monitrc"
_shell="/bin/bash"

case "$1" in
	run)
    echo "Running Monit... "
    exec /usr/bin/monit -d 10 -Ic /etc/monitrc
		;;
	stop)
		$_cmd stop all
    RETVAL=$?
		;;
	restart)
		$_cmd restart all
    RETVAL=$?
		;;
  shell)
    $_shell
    RETVAL=$?
		;;
	status)
		$_cmd status all
    RETVAL=$?
		;;
  summary)
		$_cmd summary
    RETVAL=$?
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|shell|status|summary}"
		RETVAL=1
esac
