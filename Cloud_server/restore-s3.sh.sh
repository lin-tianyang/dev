#!/bin/bash
#############################################################
# Description:用于批量恢复误删除s3数据，需要开版本控制才行  #
# date:    2019-12-25                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com 			    #
# Example:/bin/bash restore.sh 10 10 gt-logbus wam/2019-10  #
#############################################################
#$1==日期 $2==月份 $3==存储桶 $4==路径  wam/2019-10/10/
nowyear="2019"
nowmouth="$2"
nowdate="$1"
s3pwd="$4"
mkdir -p /data/test
cd /data/test/

DeleteMarkers=`aws s3api list-object-versions --bucket $3  --prefix $s3pwd | cat -n   | grep DeleteMarkers | awk '{print $1}'`

aws s3api list-object-versions --bucket $3  --prefix $s3pwd | head -n $DeleteMarkers | grep -i key | awk -F ':' '{print $2}' | awk -F ',' '{print $1}'  > /data/test/22
sed -i '1d'  /data/test/22
#需要注意格式
cat 22 |awk -F '/' '{print $3}' | awk -F '"' '{print $1}' >/data/test/33

aws s3api list-object-versions --bucket $3  --prefix $s3pwd | head -n $DeleteMarkers | grep -i VersionId | awk -F ':' '{print $2}' | awk -F ',' '{print $1}' > /data/test/55
sed -i '1d'  /data/test/55

number=`awk 'END{print NR}' /data/test/22`


for i in `seq 1 $number`
do
  echo "aws s3api get-object --bucket $3 --key" >>/data/test/11
  echo "--version-id" >>/data/test/44
done


paste /data/test/11 /data/test/22 /data/test/33 /data/test/44 /data/test/55 >>/data/test/66.sh

/bin/bash /data/test/66.sh
#rm -f  11 22 33 44 55 66 66.sh 
#aws s3 sync /data/test/ s3://$3/$s3pwd
#mv /data/test/lloki1ovx79c_2019-09* /data/test1/
#mv /data/test/q8td5nc2yz28_2019-09* /data/test1/
