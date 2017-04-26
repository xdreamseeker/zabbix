#!/bin/sh
#返回oracle 实例信息
n1=`ps -ef|grep ora_pmon|grep -v grep|wc -l`
if [ $n1 -gt 0 ]
then
sidraw=`ps -ef|grep ora_pmon|grep -v grep|awk '{print $9}'`
result="{"
result=$result"\"data\":["
i=1
for msid in $sidraw
do 
  if [ $i -lt $n1 ] 
  then  
    result=$result"{\"{#ORAPIDNAME}\":\"$msid\"},"
  else
    result=$result"{\"{#ORAPIDNAME}\":\"$msid\"}]}"
  fi
  i=`expr $i + 1 `
done
echo "$result"
fi