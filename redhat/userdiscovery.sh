#!/bin/bash
usersraw=`grep bash /etc/passwd | cut -d ":" -f 1`

read -a users <<<$usersraw

result="{"
result=$result"\"data\":["

for ((i=0;i<${#users[@]};i++)); do

result=$result"{\"{#USER}\":\"${users[i]}\"},"

done

result=${result:0:${#result}-1} 
result=$result"]}"
echo $result

