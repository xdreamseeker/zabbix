if [ $# != 1 ]
then
echo "Command format: $0  \"ORACLE_SID\" \n"
exit
fi
export ORACLE_SID=$1
echo $ORACLE_SID
sqlplus -S /nolog<<EOF
connect / as sysdba
set linesize 1024;
select name, created, log_mode,flashback_on from v\$database;
select instance_number, instance_name,host_name,archiver,database_status from v\$instance;
show parameter recovery;
select * from v\$flash_recovery_area_usage;
select * from v\$log;
select property_name,property_value from database_properties where property_name like '%CHARACTERSET%';

exit;
EOF
