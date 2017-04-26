#!/bin/bash
if [ `ps -ef|grep pmon|grep -v grep|grep -v ASM|wc -l` -gt 0 ] ; then
	#2016.6.22 solve ioctl for device problem
	source /home/oracle/.bash_profile 2>/dev/null
	#only one parameter 
	if [ $# -eq 0 ] ; then
		sidraw=`ps -ef|grep ora_pmon|grep -v grep|grep -v ASM|awk '{print $8}'`
		read -a sids <<<$sidraw
		result="{"
		result=$result"\"data\":["
		for ((i=0;i<${#sids[@]};i++)); do
			sid=${sids[i]}
			sid=${sid:9}
			export ORACLE_SID=$sid
			#2016.6.22 time problem
			sqlresult=`sqlplus -S /nolog <<EOF
			connect / as sysdba;
			set echo off feedback off heading off underline off;
			set timing off;
			select value from v\\$diag_info where name ='Diag Trace';
			exit;
			EOF`
			sqlresult=${sqlresult}'/alert_'${sids[i]}'.log'
			sqlresult=`echo $sqlresult`
			result=$result"{\"{#ALERTFILE}\":\"$sqlresult\"},"
		done
		result=${result:0:${#result}-1} 
		result=$result"]}"
		if [ `echo $sqlresult |grep ERROR|grep -v grep|wc -l` -gt 0 ]
		then
		result="oracle is down"
		fi
		if [ `echo $sqlresult |grep Error|grep -v grep|wc -l` -gt 0 ]
		then
		result="oracle is down"
		fi
	fi
	echo $result
fi
