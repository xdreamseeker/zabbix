#!/bin/sh
#������ʱ����ÿ��������һ��zabbix agent 
install_zbx_cron(){
        if [ `sed  -n '/service zabbix_agentd restart/p' /var/spool/cron/root|wc -l` -eq 0 ]; then
                echo "0 3 * * 1 . /etc/profile;service zabbix_agentd restart">>/var/spool/cron/root
                crontab /var/spool/cron/root
                chkconfig --level 12345 crond on
                service crond reload
                return 1
        else
                return 0
        fi
}

#������ʱ����ÿ5���ӳ�������һ��zabbix agent
install_zbx_start(){
        if [ `sed  -n '/service zabbix_agentd start/p' /var/spool/cron/root|wc -l` -eq 0 ]; then
                echo "*/5 * * * * . /etc/profile;service zabbix_agentd start">>/var/spool/cron/root
                crontab /var/spool/cron/root
                chkconfig --level 12345 crond on
                service crond reload
                return 1
        else
                return 0
        fi
}


install_zbx_start

install_zbx_cron
