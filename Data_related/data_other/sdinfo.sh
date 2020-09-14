#!/bin/bash
#############################################################
# Description:上传ksr日志到s3存储桶上.hour-version          #
# date:    2019-12-25                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################
gtyear=`date  +%Y -d '1 day ago'`
gtmouth=`date  +%m -d '1 day ago'`
#gtday=`date  +%d -d '1 day ago'`
gthour=`date  +%H -d '1 day ago'`
gttime=`date +"%Y年%m月%d日" -d '1 day ago'`
ksrpwd="/data/gt-logbus/ksr-logbus"
logrsa="/usr/local/shell/rsa/bigdata.pem"

for  i in  `seq 11 15`
do 

gtday=`printf "%02d\n" $i`
aws s3 cp s3://gt-logbus/ksr/$gtyear-$gtmouth/ksr-10001-zsjefunbm_cron1_"$gtyear""$gtmouth""$gtday".tar.gz  /data/test111/

cd  /data/test111/

tar xzvf ksr-10001-zsjefunbm_cron1_"$gtyear""$gtmouth""$gtday".tar.gz '*club_info.json' '*hero_info.json' '*item_info.json' '*player_info.json' '*son_info.json' '*wife_info.json' --strip-components 1  -C .

cd zsjefunbm_cron1_"$gtyear""$gtmouth""$gtday"

tar czvf ksr-10001-info_"$gtyear""$gtmouth""$gtday".tar.gz *

mv ksr-10001-info_"$gtyear""$gtmouth""$gtday".tar.gz /data/gamelogs_ksr/gz/

echo $gttime >>/usr/local/shell/logbus.txt

done
