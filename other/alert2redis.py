#!/usr/bin/python
# coding=utf-8

import redis, sys, json, time

reload(sys)
sys.setdefaultencoding('utf-8')

# db1:
# new add message:
# new del message
# still on message
# db3:message info
# solve message in db

rdshost = "10.21.39.101"
rdsport = 6379
rdspwd = "itauto"
r0 = redis.StrictRedis(host=rdshost, port=rdsport, db=0, password=rdspwd)
r2 = redis.StrictRedis(host=rdshost, port=rdsport, db=2, password=rdspwd)

if __name__ == "__main__":
    print sys.argv
    data = {'ipaddr': sys.argv[1],
            'oid': sys.argv[2],
            'state': sys.argv[3],
            'title': sys.argv[4],
            'desc': sys.argv[5],
            'raise_time': time.strftime('%Y-%m-%d %X', time.localtime(time.time()))
            }

    jsondata = json.dumps(data, ensure_ascii=False)

    if data['state'] == 'OK':
        r0.lrem("alert_raise_mq", 0, data['oid'])
        r0.lpush("alert_recovery_mq", data['oid'])

    elif data['state'] == 'High':
        r0.lpush("alert_raise_mq", data['oid'])
        r0.set("last_high_alert_time", data['raise_time'])
        r2.set(data['oid'], jsondata)

    elif data['state'] == 'Disaster':
        r0.lpush("alert_raise_mq", data['oid'])
        r0.set("last_disaster_alert_time", data['raise_time'])
        r2.set(data['oid'], jsondata)

    else:
        r0.lpush("alert_raise_mq", data['oid'])
        r0.set("last_alert_time", data['raise_time'])
        r2.set(data['oid'], jsondata)
