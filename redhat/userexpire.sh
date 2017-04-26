#!/bin/bash
expired() {
	PAS_DATE=$(passwd -S $1 | awk '{print $3}')
	PAS_DATE_UTC=$(date -d "$PAS_DATE" +%s)
	CUR_DATE_UTC=$(date +%s)
	DIFF_S=$(($CUR_DATE_UTC - $PAS_DATE_UTC))
	DIFF_DAYS=$(($DIFF_S/86400))
	PASS_AGE=$(passwd -S $1 | awk '{print $5}')
	EXP_DAYS=$(($PASS_AGE - $DIFF_DAYS))
	
	echo $EXP_DAYS
}

user=$1
res=`expired $user`
echo $res