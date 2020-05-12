#!/bin/bash
#############################################################
# Description:上传ksr日志到s3存储桶上                       #
# date:    2019-09-15                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################


gtyear=`date  +%Y -d '-2 hour'`
gtmouth=`date  +%m -d '-2 hour'`
gtday=`date  +%d -d '-2 hour'`
gthour=`date  +%H -d '-2 hour'`
gttime=`date +"%Y年%m月%d日%H时" -d '-2 hour'`
ksrpwd="/data/gt-logbus/ksr-logbus"

khln=`cd $ksrpwd/hour/  && ls *$gtyear$gtmouth$gtday$gthour.tar.gz   | wc -l`
kwn=`aws ec2 describe-instances | grep '"Value": "ksr*' | grep -v "ksr 测试服" | sort |uniq |wc -l`
#kwn=`aws ec2 describe-instances | grep '"Value": "ksr*' | sort |uniq |wc -l`
if [ $khln == $kwn ] 
then

aws s3 sync $ksrpwd/hour s3://gt-logbus/ksr-hour/$gtyear-$gtmouth/$gtday --exclude "*" --include "*"$gtyear""$gtmouth""$gtday""$gthour".tar.gz"
#aws s3 sync /data/gt-logbus/wst/wst-logbus/hour/ s3://gt-logbus/wst/wst-hour/$gtyear-$gtmouth/$gtday  --exclude "*" --include "WST-10009-$gtyear-$gtmouth-$gtday_$gthour*"
#find  /data/gt-logbus/wst/wst-logbus/hour/ -mtime +10 |  xargs rm
find  $ksrpwd/day/ -mtime +10  |  xargs rm
find  $ksrpwd/hour/ -mtime +5 |  xargs rm

ksrlog=`aws s3 ls s3://gt-logbus/ksr-hour/$gtyear-"$gtmouth"/$gtday/ | grep "$gtyear""$gtmouth""$gtday""$gthour" | wc -l`
ksrlogsize=`aws s3 ls s3://gt-logbus/ksr-hour/$gtyear-$gtmouth/$gtday/ | grep "$gtyear""$gtmouth""$gtday""$gthour" | awk '{sum+=$3} END {print sum/1024/1024"单位M"}'`
echo "&&&ksr.$gttime,$ksrlog,$ksrlogsize" >>/usr/local/shell/check/logstatus.txt
#python /etc/zabbix/shell/gtlog.py   ksr-s3上小时日志数量为$ksrlog,总大小为$ksrlogsize ksr日志日期:$gttime
curl -d "status=success&date=$gtyear-$gtmouth-$gtday-$gthour" http://159.138.136.163:8000/api/gamelogs/ksrrealtime/


else
aws s3 sync $ksrpwd/hour s3://gt-logbus/ksr-hour/$gtyear-$gtmouth/$gtday --exclude "*" --include "*"$gtyear""$gtmouth""$gtday""$gthour".tar.gz"
python /etc/zabbix/shell/gtlog.py "ksr上传日志数量可能有问题:$gttime"  "ksr文件:$khln,ksrWeb服务器数量为$kwn"

fi


