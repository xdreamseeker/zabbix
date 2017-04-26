#!/bin/bash
if [ ! -f "/opt/DynamicLinkManager/bin/dlnkmgr" ]; then
  echo 0
  exit 0
fi

res=`/opt/DynamicLinkManager/bin/dlnkmgr view -lu |grep Offline|wc -l`
echo $res