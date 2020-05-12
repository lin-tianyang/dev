#!/bin/bash

set -o pipefail
db='goatgames'
host='localhost'
#datetime='2019-05-27 16:00:01'
tarfile=$(date  +%Y%m%d)
timeDiff='16:00:00'
serverCurTime=$(date +%Y-%m-%d)
dbEndTime="$serverCurTime $timeDiff"
serverLastDayTime=$(date   -d "-1 day" +%Y-%m-%d)
dbStartTime="$serverLastDayTime $timeDiff"
gttime=`date +"%Y年%m月%d日%H时"`
## 正式跑
startime=$dbStartTime
datetime=$dbEndTime
>/usr/local/shell/check/gtsdk.txt
## 历史数据跑
#starttime="2019-05-21 $timeDiff"
#datetime="2019-05-27 $timeDiff"
# datetime=$(date    +%Y-%m-%d" "%H:%M:%S)
# starttime=$(date   -d "last day" +%Y-%m-%d" "%H:%M:%S)
#startime='2019-05-21 16:00:01'
# tartime=$(date +%Y%m%d)
#src_table='t_game_partners'
#dest_table='t_game_total_partners'
#columns="gpid,partnerName,siteCode,createdTime,modifiedBy,modifiedTime"
dest_dir="/usr/local/shell/txt"
#logfile="/data/rsync/kq_t_game_partners.log"
#outfile="$dest_dir/kq_t_game_partners-$datetime.txt"
#start_file="/data/rsync/kq_t_game_partners_start.txt"
#start_id=$(cat $start_file)

cd $dest_dir
mkdir -p   /usr/local/shell/backup/
cp  *.gz  /usr/local/shell/backup/
find /usr/local/shell/backup/ -mtime +7 -name "*.gz"| xargs rm
rm -f *.txt *.gz

gtslave=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf    -e 'show slave status\G' |grep -E 'Slave_IO_Running|Slave_SQL_Running' | grep -i yes |wc -l`
gtlock=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e  "show OPEN TABLES where In_use > 0;" |wc -l`

if [[ $gtslave -eq 2 ]] &&  [[ $gtlock -eq 0 ]] 
then 
mysql -N -D$db -e "SELECT user_id,if(belong='ios',CONCAT(game_id,belong),game_id) AS game_id,platform thirdPlate,s_id serverCode,order_id efunOrderId,cp_order_id thirdOrderId,currency,r_id creditId,DATE_ADD(created_at, INTERVAL 8 HOUR) as orderTime,DATE_ADD(complete_at, INTERVAL 8 HOUR) as modifiedTime,amount usd FROM orders
WHERE status in ('complete','payment') and s_id != 999   and sandbox = 0  and  paid_at >='$startime' AND paid_at<'$datetime' and orders.user_id NOT IN (SELECT user_id FROM test_users);" >>$dest_dir/orders.txt

mysql -N -D$db -e "SELECT user_id,if(belong='ios',CONCAT(game_id,belong),game_id) AS game_id,platform thirdPlate,belong platform,ad_id,ip,DATE_ADD(created_at,INTERVAL 8 HOUR) as  registerTime,iso_code AS address  
FROM games_register_log WHERE created_at>='$startime' AND created_at<'$datetime' AND games_register_log.user_id NOT IN (SELECT user_id FROM test_users);"  >>$dest_dir/games_register_log.txt

#mysql -N -D$db -e "SELECT min(DATE_ADD(created_at, INTERVAL 8 HOUR)) as firstLogin,max(DATE_ADD(created_at, INTERVAL 8 HOUR))  aslastLogin,user_id,if(belong='ios',CONCAT(game_id,belong),game_id) AS game_id,platform,belong,MAX(ad_id ),MAX(ip),COUNT(*) loginCnt,MAX(iso_code) AS countryCode,MAX(city) AS cityCode FROM games_login_log WHERE created_at>='$startime' AND created_at<'$datetime' AND  games_login_log.user_id NOT IN (SELECT user_id FROM test_users) GROUP BY user_id,game_id,belong,platform;" >>$dest_dir/games_login_log.txt
mysql -N -D$db -e "SELECT min(DATE_ADD(created_at, INTERVAL 8 HOUR)) as firstLogin,max(DATE_ADD(created_at, INTERVAL 8 HOUR))  aslastLogin,user_id,if(belong='ios',CONCAT(game_id,belong),game_id) AS game_id,platform,belong,MAX(ad_id ),MAX(ip),COUNT(*) loginCnt,MAX(iso_code) AS countryCode,MAX(city) AS cityCode FROM games_login_log WHERE created_at>='$startime' AND created_at<'$datetime' AND  games_login_log.user_id NOT IN (SELECT user_id FROM test_users) GROUP BY user_id,game_id,belong,platform;" >>$dest_dir/games_login_log.txt
tar czvf gt-$tarfile.tar.gz  *.txt

#sleep  300
rsync -avz --progress --bwlimit=3000 --password-file=/etc/rsyncd/server.pass  $dest_dir/*.tar.gz efun@211.72.207.175::gamelogs/goat/ && echo "order表:$gtorder,register表:$gtregister,login表:$gtlogin,压缩包:$gttar,$gttime" >/usr/local/shell/check/gtsdk.txt

gtorder=`cat $dest_dir/orders.txt |wc -l`
gtregister=`cat $dest_dir/games_register_log.txt | wc -l`
gtlogin=`cat $dest_dir/games_login_log.txt |wc -l`
gttar=`zcat $dest_dir/gt-$tarfile.tar.gz | wc -l`
gtrsync=`cat /usr/local/shell/check/gtsdk.txt | grep $gttime | wc -l`
#echo "order表:$gtorder,register表:$gtregister,login表:$gtlogin,压缩包:$gttar,$gttime" >>/usr/local/shell/check/gtsdk.txt


        if [ $gtrsync -eq 1  ]  || [ $gttar -eq 1  ]
        then
                #echo "rsync取值为$gtrsync,压缩包取值为$gttar"|mail -s "高图sdk传输告警" b43ec1e6-00e2-4b8d-b66e-e192e7a154afgt@camail.aiops.com
                python  /etc/zabbix/shell/gtlog.py   "order表:$gtorder,register表:$gtregister,login表:$gtlogin,压缩包:$gttar" "gtrsync:$gtrsync,sdk日志:$gttime"
    
        else
                #python  /etc/zabbix/shell/gtlog.py   "order表:$gtorder,register表:$gtregister,login表:$gtlogin,压缩包:$gttar" "gtrsync:$gtrsync,sdk日志:$gttimegt"
                curl -H "Content-type: application/json" -X POST     -d '{
                "app": "xxx",
                "eventId": "12345",
                "eventType": "trigger",
                "alarmName": "gtsdk传输告警",
                "entityName": "gtsdk",
                "priority": 1,
                "alarmContent":"'rsync取值为“$gtrsync”','压缩包取值为“$gttar”'"
                }'  "http://xxx/alert/api/event"
        fi
else
#python  /etc/zabbix/shell/gtlog.py   "数据库可能存在问题"   "主从:$gtslave,锁表:$gtlock"
                curl -H "Content-type: application/json" -X POST     -d '{
                "app": "xxx",
                "eventId": "12345",
                "eventType": "trigger",
                "alarmName": "数据库可能存在问题",
                "entityName": "gtdb",
                "priority": 1,
                "alarmContent":"'主从:$gtslave','锁表:$gtlock'"
                }'    "http://xxx/alert/api/event"
#echo "主从:$gtslave,锁表:$gtlock"|mail -s "数据库可能存在问题" b43ec1e6-00e2-4b8d-b66e-e192e7a154afgt@camail.aiops.com
fi





