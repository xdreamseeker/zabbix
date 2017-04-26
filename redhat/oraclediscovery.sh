#!/bin/bash
if [ `ps -ef|grep ora_pmon|grep -v grep|wc -l` -gt 0 ]
then

#2016.6.22 solve ioctl for device problem
source /home/oracle/.bash_profile 2>/dev/null

sidraw=`ps -ef|grep ora_pmon|grep -v grep|grep -v ASM|awk '{print $8}'`

read -a sids <<<$sidraw

result="{"
result=$result"\"data\":["

for ((i=0;i<${#sids[@]};i++)); do
sid=${sids[i]}
sid=${sid:9}
result=$result"{\"{#ORACLESID}\":\"$sid\"},"

done

result=${result:0:${#result}-1} 
result=$result"]}"
echo $result

fi
