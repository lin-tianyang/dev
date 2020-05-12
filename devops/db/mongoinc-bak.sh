#!/bin/bash
# Author:lty
#每周礼拜2-7做增量备份
host='xxx'
serverport='37017'
globalport='37018'
serverpath='/data/wstdb-backup/wstdb-server/Increment'
globalpath='/data/wstdb-backup/wstdb-global/Increment'
#备份时间戳
nowtime=`date +%y%m%d`
上一次备份的时间，和这一次的截止时间
starttime=`cat /data/wstdb-backup/wsttag.txt`
stoptime=`date +%s`

#mongodump --host $host --port $serverport   -d local  -c oplog.rs  --query '{ts:{$gte:Timestamp('1586756287',1)}' -o /data/test1/

#指定起始备份点和，完整备份点 
mongodump --host $host --port $serverport -d local  -c oplog.rs  --query '{ts:{$gte:Timestamp('$starttime',1),$lte:Timestamp('$stoptime',9999)}}' -o ${serverpath}/${nowtime}
mongodump --host $host --port $globalport -d local  -c oplog.rs  --query '{ts:{$gte:Timestamp('$starttime',1),$lte:Timestamp('$stoptime',9999)}}' -o ${globalpath}/${nowtime}
  
echo "$stoptime" >/data/wstdb-backup/wsttag.txt

#删除14天以前的记录
keepbaktime=$(date -d '-14 days' "+%Y%m%d")
if [ -d $serverpath/$keepbaktime]; then
    rm -rf $bkdatapath/$keepbaktime
    echo "Message -- $bkdatapath/mongodboplog$keepbaktime 删除完毕" >> /data/wstdb-backup/delete.log
fi

if [ -d $globalpath/$keepbaktime ]; then
    rm -rf $bkdatapath/$keepbaktime
    echo "Message -- $bkdatapath/mongodboplog$keepbaktime 删除完毕" >> /data/wstdb-backup/delete.log
fi
 


