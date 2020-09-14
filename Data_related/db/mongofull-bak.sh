#!/bin/bash
# Author:lty

#还原 mongorestore --host 2.2.2.22 --port 37017 --oplogReplay /data/test1
host='172.28.1.219'
serverport='37017'
serverpath='/data/wstdb-backup/wstdb-server/full'
globalport='37018'
globalpath='/data/wstdb-backup/wstdb-global/full'
nowtime=$(date "+%Y%m%d")
 
 
 
start(){
    /bin/mongodump --host $host --port $serverport --oplog --gzip --out ${serverpath}/${nowtime}
    /bin/mongodump --host $host --port $globalport --oplog --gzip --out ${globalpath}/${nowtime}
}
 

#删除21天以前的全备,保留2次的全备 
backtime=$(date -d '-21 days' "+%Y%m%d")
if [ -d "${targetpath}/${backtime}/" ];then
    rm -rf "${targetpath}/${backtime}/"
    echo "=======${targetpath}/${backtime}/===删除完毕=="
fi
 
start
echo "========================= $(date) backup all mongodb back end ${nowtime}========="
