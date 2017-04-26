#!/bin/bash
if [ `ps -ef|grep pmon|grep ASM|grep -v grep|wc -l` -gt 0 ]
then

#echo $0
#echo $1
#echo $2
#echo $3
source /home/grid/.bash_profile
export ORACLE_SID=`ps -ef|grep pmon|grep ASM|grep -v grep|cut -d _ -f3`


if [ $# -eq 0 ] ; then
#echo $ORACLE_SID
sqlresult=`sqlplus -S /nolog <<EOF
connect / as sysasm
set echo off feedback off heading off underline off;
select name from v\\$asm_diskgroup where 1=1;
exit;
EOF`

result="{"
result=$result"\"data\":["

read -a DGS <<<$sqlresult
for ((i=0;i<${#DGS[@]};i++)); do
result=$result"{\"{#DGNAME}\":\"${DGS[i]}\"},"
done

result=${result:0:${#result}-1}
result=$result"]}"
echo $result


elif [ $2 == "free" ] ; then
result=`sqlplus -S /nolog <<EOF
connect / as sysasm
set echo off feedback off heading off underline off;
select free_mb from v\\$asm_diskgroup where name='$1';
exit;
EOF`
typeset -i result
echo $result

elif [ $2 == "total" ] ; then
result=`sqlplus -S /nolog <<EOF
connect / as sysasm
set echo off feedback off heading off underline off;
select total_mb from v\\$asm_diskgroup where name='$1';
exit;
EOF`
typeset -i result
echo $result


elif [ $2 == "pfree" ] ; then
result=`sqlplus -S /nolog <<EOF
connect / as sysasm
set echo off feedback off heading off underline off;
select free_mb/total_mb*100 from v\\$asm_diskgroup where name='$1';
exit;
EOF`
typeset -i result
echo $result

fi

fi
