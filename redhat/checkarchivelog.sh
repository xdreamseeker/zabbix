#!/bin/bash
sid=$1

#2016.6.22 solve ioctl for device problem
source /home/oracle/.bash_profile 2>/dev/null

export ORACLE_SID=$sid
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysdba;
set echo off feedback off heading off underline off;
set timing off;
select ceil(sum(ru.percent_space_used * case when db.log_mode <> 'ARCHIVELOG' then 0 else 1 end )) percent_space_used \
from sys.v_\\$recovery_area_usage ru \
inner join sys.v_\\$database db on 1=1;
exit;
EOF`

typeset -i sqlresult
echo $sqlresult