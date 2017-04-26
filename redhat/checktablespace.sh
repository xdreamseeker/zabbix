#!/bin/bash
if [ `ps -ef|grep ora_pmon|grep -v grep|grep -v ASM|wc -l` -gt 0 ]
then

#2016.6.22 solve ioctl for device problem
source /home/oracle/.bash_profile 2>/dev/null


if [ $# -eq 0 ] ; then
#2017.2.23 fix some pmon oracle sid bug
#2017.3.28 fix some pmon oracle sid bug _
sidraw=`ps -ef|grep ora_pmon|grep -v grep|grep -v ASM|awk '{print $8}'`
read -a sids <<<$sidraw


result="{"
result=$result"\"data\":["

#echo ${#sids[@]}
for ((i=0;i<${#sids[@]};i++)); do
sid=${sids[i]}
sid=${sid:9}
export ORACLE_SID=$sid
#echo $ORACLE_SID
#2016.6.21 add "not monitor auto extend tablespace"
#2016.6.22 time problem
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
set timing off;
select tablespace_name from dba_tablespaces \
minus \
select tablespace_name from DBA_DATA_FILES where autoextensible='YES';
exit;
EOF`


#echo $sqlresult
read -a tablespaces <<<$sqlresult
for ((j=0;j<${#tablespaces[@]};j++)); do
result=$result"{\"{#TSNAME}\":\"$sid:${tablespaces[j]}\"},"
done
done
result=${result:0:${#result}-1} 
result=$result"]}"

#2016.6.23 sovle when oracle down,get wrong data
if [ `echo $sqlresult |grep ERROR|grep -v grep|wc -l` -gt 0 ]
then
result="oracle is down"
fi

echo $result


elif [ $2 == "free" ] ; then
sid=`echo $1|cut -d : -f1`
ts=`echo $1|cut -d : -f2`
#echo $sid
#echo $ts
export ORACLE_SID=$sid
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
set timing off;
select Free_space from (SELECT Total.name, \
Free_space, total_space,(Free_space/total_space*100) pfree \
FROM \
(select tablespace_name, sum(bytes/1024/1024) Free_Space \
from sys.dba_free_space \
group by tablespace_name \
) Free, \
(select b.name, sum(bytes/1024/1024) TOTAL_SPACE \
from sys.v_\\$datafile a, sys.v_\\$tablespace B \
where a.ts# = b.ts# \
group by b.name \
) Total \
WHERE Free.Tablespace_name = Total.name) where name='$ts';
exit;
EOF`

typeset -i sqlresult
echo $sqlresult


elif [ $2 == "total" ] ; then
sid=`echo $1|cut -d : -f1`
ts=`echo $1|cut -d : -f2`
#echo $sid
#echo $ts
export ORACLE_SID=$sid
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
set timing off;
select total_space from (SELECT Total.name, \
Free_space, total_space,(Free_space/total_space*100) pfree \
FROM \
(select tablespace_name, sum(bytes/1024/1024) Free_Space \
from sys.dba_free_space \
group by tablespace_name \
) Free, \
(select b.name, sum(bytes/1024/1024) TOTAL_SPACE \
from sys.v_\\$datafile a, sys.v_\\$tablespace B \
where a.ts# = b.ts# \
group by b.name \
) Total \
WHERE Free.Tablespace_name = Total.name) where name='$ts';
exit;
EOF`

typeset -i sqlresult
echo $sqlresult




elif [ $2 == "pfree" ] ; then

sid=`echo $1|cut -d : -f1`
ts=`echo $1|cut -d : -f2`
#echo $sid
#echo $ts
export ORACLE_SID=$sid
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
set timing off;
select pfree from (SELECT Total.name, \
Free_space, total_space,(Free_space/total_space*100) pfree \
FROM \
(select tablespace_name, sum(bytes/1024/1024) Free_Space \
from sys.dba_free_space \
group by tablespace_name \
) Free, \
(select b.name, sum(bytes/1024/1024) TOTAL_SPACE \
from sys.v_\\$datafile a, sys.v_\\$tablespace B \
where a.ts# = b.ts# \
group by b.name \
) Total \
WHERE Free.Tablespace_name = Total.name) where name='$ts';
exit;
EOF`

typeset -i sqlresult
echo $sqlresult

fi

fi
