#!/bin/sh
#every 5min start zabbix 
install_zbx_start(){
if [ `cat /var/spool/cron/crontabs/root | grep /zabbix/sbin/zabbix_agentd | wc -l` -eq 0 ]; then
	echo '0,5,10,15,20,25,30,35,40,45,50,55 * * * * /zabbix/sbin/zabbix_agentd' >>  /var/spool/cron/crontabs/root
	echo "install every 5min"
else
	echo "do nothing"
fi
}

#every week stop zabbix
install_zbx_cron(){
if [ `cat /var/spool/cron/crontabs/root | grep "kill -9 \`ps -ef|grep zabbix|grep -v grep|awk \'{print \$2}\'\`" | wc -l` -eq 0 ]; then
	echo "0 3 * * 1 kill -9 `ps -ef|grep zabbix|grep -v grep|awk '{print $2}'`">> /var/spool/cron/crontabs/root
	echo "install every week"
else
	echo "do nothing"
fi
}


install_zbx_start

install_zbx_cron
