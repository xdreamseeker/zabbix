#!/bin/bash
if [ `ps -ef|grep pmon|grep -v grep|grep -v ASM|wc -l` -gt 0 ]
then

#echo $0
#echo $1
#echo $2
#echo $3
source /home/oracle/.bash_profile


if [ $# -eq 0 ] ; then

sidraw=`ps -ef|grep pmon|grep -v grep|grep -v ASM|cut -d _ -f3`
read -a sids <<<$sidraw


result="{"
result=$result"\"data\":["

#echo ${#sids[@]}
for ((i=0;i<${#sids[@]};i++)); do
export ORACLE_SID=${sids[i]}
#echo $ORACLE_SID
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
SELECT Total.name FROM  \
(select tablespace_name, sum(bytes/1024/1024) Free_Space \
from sys.dba_free_space \
group by tablespace_name) Free, \
(select b.name, sum(bytes/1024/1024) TOTAL_SPACE \
from sys.v_\\$datafile a, sys.v_\\$tablespace B \
where a.ts# = b.ts# \
group by b.name) Total  \
WHERE Free.Tablespace_name = Total.name;
exit;
EOF`

#echo $sqlresult
read -a tablespaces <<<$sqlresult
for ((j=0;j<${#tablespaces[@]};j++)); do
result=$result"{\"{#TSNAME}\":\"${sids[i]}:${tablespaces[j]}\"},"
done
done

result=${result:0:${#result}-1} 
result=$result"]}"
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
