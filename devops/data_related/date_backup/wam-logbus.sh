#!/bin/bash
#############################################################
# Description:上传ksr日志到s3存储桶上                       #
# date:    2019-09-15                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################
gtyear=`date  +%Y -d '1 day ago'`
gtmouth=`date  +%m -d '1 day ago'`
gtday=`date  +%d -d '1 day ago'`
gthour=`date  +%H -d '1 day ago'`
gttime=`date +"%Y年%m月%d日" -d '1 day ago'`
pgtyear=`date  +%Y -d '2 day ago'`
pgtmouth=`date  +%m -d '2 day ago'`
pgtday=`date  +%d -d '2 day ago'`

pwdwam="/data/gt-logbus/wam-logbus"
#mkdir -p  $pwdwam/wam-sync/$gtyear-$gtmouth/$gtday
#cd        $pwdwam/EfunOut/
#cp *$gtyear-$gtmouth-$gtday* $pwdwam/wam-sync/$gtyear-$gtmouth/$gtday/
#aws s3 sync $pwdwam/wam-sync/$gtyear-$gtmouth/$gtday/  s3://gt-logbus/wam/"$gtyear"-"$gtmouth"/$gtday/
pwamlog=`aws s3 ls s3://gt-logbus/wam/$pgtyear-$pgtmouth/$pgtday/ | grep $pgtyear-$pgtmouth-$pgtday.tar.gz | wc -l`
wamdaylog=`ls /data/gt-logbus/wam-logbus/EfunOut | grep $gtyear-$gtmouth-$gtday.tar.gz | wc -l`
wamlog=`aws s3 ls s3://gt-logbus/wam/$gtyear-$gtmouth/$gtday/ | grep $gtyear-$gtmouth-$gtday.tar.gz | wc -l`
wamlogsize=`aws s3 ls s3://gt-logbus/wam/$gtyear-$gtmouth/$gtday/ | grep $gtyear-$gtmouth-$gtday.tar.gz | awk '{sum+=$3} END {print sum/1024/1024"单位M"}'`
if [ $wamdaylog -ge $pwamlog ]
then	
aws s3 sync /data/gt-logbus/wam-logbus/EfunOut s3://gt-logbus/wam/$gtyear-$gtmouth/$gtday/ --exclude "*"  --include "*"$gtyear"-"$gtmouth"-"$gtday".tar.gz"
find  $pwdwam/EfunOut/ -mtime +10 |  xargs rm   
#find  $pwdwam/wam-sync/$gtyear-$gtmouth/ -mtime +0 |  xargs rm
#python2 /etc/zabbix/shell/gtlog.py   wam当天s3上压缩包日志数量为$wamlog,总大小为$wamlogsize wam日志日期:$gttime
#python2 /usr/lib/zabbix/alertscripts/shengtangaltert.py   wam当天s3上压缩包日志数量为$wamlog,总大小为$wamlogsize,请原厂确认是否完整  wam日志日期:$gttime

echo "$gttime,$wamlog,$wamlogsize,wam" >>/usr/local/shell/check/logstatus.txt
curl -d "status=success&date=$gtyear-$gtmouth-$gtday" http://xxx:8000/api/gamelogs/wam/
else
python2 /etc/zabbix/shell/gtlog.py   wam当天s3上压缩包日志数量为$wamlog,总大小为$wamlogsize,可能存在问题 wam日志日期:$gttime
fi

