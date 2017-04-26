#!/bin/sh
#�������е�oracle rac����dg��С��ʹ�����ͳ��
#author��liujun 
#date��2017-3-22
#function
#��ȡDGʹ�����
#������ args1 : instance name (���ݿ�ʵ������
#       args2 : free��total
#       args3 : tablespacename
#����� ��ѯ���Ĵ�С����λM��
getdgsize()
{
   f_inst=$1
   f_type=$2
   f_tbs=$3
if [ $f_type = "free" ] 
then
#  echo "ZABBIX_MON:getdgsize1:dbinst:$f_inst:type:$f_type:tbs:$f_tbs"
  
su - grid <<!!
  export ORACLE_SID=$f_inst
  sqlplus -S /nolog <<EOF
  connect / as sysdba;
  set echo off feedback off heading off underline off;
  set timing off;
  select  'ZABBIX_MON',free_mb from v\\\$asm_diskgroup where name='$f_tbs';
  exit;
EOF
!!
elif [ $2 = "total" ] ; then
su - grid <<!!
  export ORACLE_SID=$f_inst
  sqlplus -S /nolog <<EOF
  connect / as sysdba;
  set echo off feedback off heading off underline off;
  set timing off;
  select  'ZABBIX_MON',total_mb from v\\\$asm_diskgroup where name='$f_tbs';
  exit;
EOF
!!
elif [ $2 = "pfree" ] ; then
su - grid <<!!
  export ORACLE_SID=$f_inst
  sqlplus -S /nolog <<EOF
  connect / as sysdba;
  set echo off feedback off heading off underline off;
  set timing off;
  select  'ZABBIX_MON',free_mb/total_mb*100 from v\\\$asm_diskgroup where name='$f_tbs';
  exit;
EOF
!!
fi
}
#��ȡdg��
#������ args1 : instance name (���ݿ�ʵ������
#����� ��ռ����б�
getdgname()
{
   f_inst=$1
#   export ORACLE_SID=$f_inst

su - grid <<!!
export ORACLE_SID=$f_inst;
sqlplus -S /nolog <<EOF
   connect / as sysasm;
   set echo off feedback off heading off underline off;
   set timing off;
   select 'ZABBIX_MON', name from v\\\$asm_diskgroup;
   exit;
EOF;
exit ;
!!
}
#######end function###########


cd /tmp
tmpsh=tmp_ora_zab_mon.sh
result=""
dbinst=""
errstr=""
tmphost=`hostname `
sqlresult=""
if [ -f $tmpsh ] 
then
   rm $tmpsh
fi 
#��ȡ�����ڱ����ϵ����ݿ���
if [ $# -eq 0 ] 
then

  dbinsts=` ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep ASM| grep -v \/  ` 
  for dbinst in $dbinsts
  do
     sqlresult="{\"data\":["
     tbsnames=`getdgname $dbinst | grep ZABBIX_MON | sed 's/ZABBIX_MON//' `
     for tbs in  $tbsnames
     do
         sqlresult=$sqlresult"{\"{#DGNAME}\":\"$tbs\"},"
     done
     sqlresult=`echo $sqlresult|sed 's/,$//g'`"]}"
     echo "$sqlresult"
  done
 
elif  [ $# -eq 2 ]
then 
   args1=$1
   dbinst=` ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep ASM| grep -v \/  ` 
  
   tbs=$1
#   echo "main4:inst:$dbinst:tbs:$tbs:type:$2"
   sqlresult=` getdgsize $dbinst $2 $tbs | grep ZABBIX_MON | sed 's/ZABBIX_MON//' `
   typeset -i sqlresult
   echo $sqlresult
fi


