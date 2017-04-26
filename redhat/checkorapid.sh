#!/bin/bash
if [ `ps -ef|grep ora_pmon|grep -v grep|wc -l` -gt 0 ]
then

sidraw=`ps -ef|grep ora_pmon|grep -v grep|awk '{print $8}'`
read -a sids <<<$sidraw

result="{"
result=$result"\"data\":["

for ((i=0;i<${#sids[@]};i++)); do

result=$result"{\"{#ORAPIDNAME}\":\"${sids[i]}\"},"

done

result=${result:0:${#result}-1} 
result=$result"]}"
echo $result

fi
