#!/bin/bash 

oldnum=`cat /usr/local/shell/check/health.txt | wc -l`

newnum=`aws health describe-events --profile fuji | grep "arn:aws:health"  | wc -l`


if  [ $newnum -gt  $oldnum ]
then
	python  /usr/lib/zabbix/alertscripts/pt-send.py  "请去https://phd.aws.amazon.com查看"  "aws有新的健康通知"  

fi

aws health describe-events --profile fuji | grep "arn:aws:health" >/usr/local/shell/check/health.txt

