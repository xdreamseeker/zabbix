#!/bin/sh
#使用srvctl 判断部署的数据库，以及数据库运行情况
#对在运行的数据进行表空间大小、使用情况统计
#author：liujun 
#date：2017-2-22
#function
#获取表空间使用情况
#参数： args1 : instance name (数据库实例名）
#       args2 : free，total
#       args3 : tablespacename
#输出： 查询到的大小（单位M）
gettbssize()
{
   f_inst=$1
   f_type=$2
   f_tbs=$3
   export ORACLE_SID=$f_inst
if [ $f_type = "free" ] 
then
#  echo "ZABBIX_MON:gettbssize1:dbinst:$f_inst:type:$f_type:tbs:$f_tbs"
  
su - oracle <<!!
	export ORACLE_SID=$f_inst
	sqlplus -S /nolog <<EOF
	connect / as sysdba;
	set echo off feedback off heading off underline off;
	set timing off;
	select 'ZABBIX_MON',Free_space from (
	select NAME,TOTAL_FREE_MB as Free_space,TOTAL_MB as total_space,TOTAL_FREE_PCT as pfree from (SELECT TOTAL.NAME, 
	ALLOC_MB - FREE_MB USED_MB,
	ALLOC_MB,
	TOTAL_MB,
	FREE_MB  ALLOC_FREE_MB, 
	FREE_MB + (TOTAL_MB - ALLOC_MB) TOTAL_FREE_MB, 
	 TRUNC((( FREE_MB)/ALLOC_MB*100),3) ALLOC_FREE_PCT,
	100 - TRUNC(((ALLOC_MB - FREE_MB)/TOTAL_MB*100),3) TOTAL_FREE_PCT
	FROM 
	(SELECT TABLESPACE_NAME, SUM(BYTES/1024/1024) FREE_MB 
	FROM SYS.DBA_FREE_SPACE
	GROUP BY TABLESPACE_NAME 
	) FREE, 
	(  SELECT TABLESPACE_NAME NAME,SUM(GREATEST(BYTES,MAXBYTES)) /1024 /1024 TOTAL_MB, SUM(BYTES) /1024 /1024 ALLOC_MB
				FROM DBA_DATA_FILES F
			   GROUP BY TABLESPACE_NAME
	) TOTAL 
	WHERE FREE.TABLESPACE_NAME = TOTAL.NAME)
	) where name='$f_tbs';
	exit;
EOF
!!
elif [ $2 = "total" ] ; then
su - oracle <<!!
	export ORACLE_SID=$f_inst
	sqlplus -S /nolog <<EOF
	connect / as sysdba;
	set echo off feedback off heading off underline off;
	set timing off;
	select 'ZABBIX_MON',total_space from (
	select NAME,TOTAL_FREE_MB as Free_space,TOTAL_MB as total_space,TOTAL_FREE_PCT as pfree from (SELECT TOTAL.NAME, 
	ALLOC_MB - FREE_MB USED_MB,
	ALLOC_MB,
	TOTAL_MB,
	FREE_MB  ALLOC_FREE_MB, 
	FREE_MB + (TOTAL_MB - ALLOC_MB) TOTAL_FREE_MB, 
	 TRUNC((( FREE_MB)/ALLOC_MB*100),3) ALLOC_FREE_PCT,
	100 - TRUNC(((ALLOC_MB - FREE_MB)/TOTAL_MB*100),3) TOTAL_FREE_PCT
	FROM 
	(SELECT TABLESPACE_NAME, SUM(BYTES/1024/1024) FREE_MB 
	FROM SYS.DBA_FREE_SPACE
	GROUP BY TABLESPACE_NAME 
	) FREE, 
	(  SELECT TABLESPACE_NAME NAME,SUM(GREATEST(BYTES,MAXBYTES)) /1024 /1024 TOTAL_MB, SUM(BYTES) /1024 /1024 ALLOC_MB
				FROM DBA_DATA_FILES F
			   GROUP BY TABLESPACE_NAME
	) TOTAL 
	WHERE FREE.TABLESPACE_NAME = TOTAL.NAME)
	) where name='$f_tbs';
	exit;
EOF
!!
elif [ $2 = "pfree" ] ; then
su - oracle <<!!
	export ORACLE_SID=$f_inst
	sqlplus -S /nolog <<EOF
	connect / as sysdba;
	set echo off feedback off heading off underline off;
	set timing off;
	select 'ZABBIX_MON',pfree from (
	select NAME,TOTAL_FREE_MB as Free_space,TOTAL_MB as total_space,TOTAL_FREE_PCT as pfree from (SELECT TOTAL.NAME, 
	ALLOC_MB - FREE_MB USED_MB,
	ALLOC_MB,
	TOTAL_MB,
	FREE_MB  ALLOC_FREE_MB, 
	FREE_MB + (TOTAL_MB - ALLOC_MB) TOTAL_FREE_MB, 
	 TRUNC((( FREE_MB)/ALLOC_MB*100),3) ALLOC_FREE_PCT,
	100 - TRUNC(((ALLOC_MB - FREE_MB)/TOTAL_MB*100),3) TOTAL_FREE_PCT
	FROM 
	(SELECT TABLESPACE_NAME, SUM(BYTES/1024/1024) FREE_MB 
	FROM SYS.DBA_FREE_SPACE
	GROUP BY TABLESPACE_NAME 
	) FREE, 
	(  SELECT TABLESPACE_NAME NAME,SUM(GREATEST(BYTES,MAXBYTES)) /1024 /1024 TOTAL_MB, SUM(BYTES) /1024 /1024 ALLOC_MB
				FROM DBA_DATA_FILES F
			   GROUP BY TABLESPACE_NAME
	) TOTAL 
	WHERE FREE.TABLESPACE_NAME = TOTAL.NAME)
	) where name='$f_tbs';
	exit;
EOF
!!
fi
}
#获取表空间名
#参数： args1 : instance name (数据库实例名）
#输出： 表空间名列表
gettbsname()
{
   f_inst=$1
#   export ORACLE_SID=$f_inst

su - oracle <<!!
export ORACLE_SID=$f_inst;
sqlplus -S /nolog <<EOF
   connect / as sysdba;
   set echo off feedback off heading off underline off;
   set timing off;
   select 'ZABBIX_MON', tablespace_name from dba_tablespaces where contents='PERMANENT';
   exit;
EOF
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
#获取部署在本机上的数据库名
if [ $# -eq 0 ] 
then

  dbinsts=` ps -ef |sed -n '/pmon/s/^.*pmon_//p'|grep -v ASM| grep -v \/  ` 
  sqlresult="{\"data\":["
  for dbinst in $dbinsts
  do
     #echo "main:2:dbinst:"$dbinst
     tbsnames=`gettbsname $dbinst | grep ZABBIX_MON | sed 's/ZABBIX_MON//' `
     for tbs in  $tbsnames
     do
         sqlresult=$sqlresult"{\"{#TSNAME}\":\"$dbinst:$tbs\"},"
     done
  done
  sqlresult=`echo $sqlresult|sed 's/,$//g'`"]}"
  echo "$sqlresult" 
elif  [ $# -eq 2 ]
then 
   args1=$1
   dbinst=`echo $args1 | cut -f1 -d: `
  
   tbs=` echo $args1 | cut -f2 -d: `
#   echo "main4:inst:$dbinst:tbs:$tbs:type:$2"
   sqlresult=` gettbssize $dbinst $2 $tbs | grep ZABBIX_MON | sed 's/ZABBIX_MON//' `
   typeset -i sqlresult
   echo "$sqlresult"
fi


