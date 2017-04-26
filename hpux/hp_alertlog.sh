#!/bin/sh
#����oracle alert log ��־�ļ�Ŀ¼
#********Alert log ��־·���б�******************************
#��ȡ
#������ args1 : instance name (���ݿ�ʵ������
#����� Alert log ��־·���б�
getalertlog()
{
   f_inst=$1
#   export ORACLE_SID=$f_inst

su - oracle <<!!
export ORACLE_SID=$f_inst;
sqlplus -S /nolog <<EOF
   connect / as sysdba;
   set echo off feedback off heading off underline off;
   set timing off;
   select 'ZABBIX_MON '|| VALUE from  v\\\$diag_info where upper(name)='DIAG TRACE';
   exit;
EOF;
exit ;
!!
}
n1=`ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep -v ASM| grep -v \/ | wc -l `
sidraw=`ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep -v ASM| grep -v \/`
if [ -n $sidraw ]
then
sidraw=`ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep -v ASM| grep -v \/`
result="{"
result=$result"\"data\":["
i=1
for msid in $sidraw
do 
  #echo "sid:$msid:----dir1:$adir"
  adir=""
  adir=` getalertlog $msid | grep ZABBIX_MON | sed 's/ZABBIX_MON//' `
  #echo "sid:$msid:----dir2:$adir"  
  if [ -n $adir ]
  then
     alog=` ls $adir/alert_*.log `
     if [ -n $alog ]
     then
        if [ $i -lt $n1 ] 
        then  
          result=$result"{\"{#ALERTFILE}\":\"$alog\"},"
        else
          result=$result"{\"{#ALERTFILE}\":\"$alog\"}]}"
        fi
        i=`expr $i + 1 `
     fi
  fi
done
echo "$result"
fi