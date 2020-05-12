#!/bin/bash
#############################################################
# Description:检查日志是否完整                              #
# date:    2019-06-13                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

#set -o
awsyear=2020
year=`date +%y`
#cronmonth=`date +%m -d '-1 month'`
#starthour=`date  +%H -d '1 hour ago'`
hour=`date  +%k`
cronday=`date +%d`
stopday=`date +%d -d '1 day ago'`
pwdksr=/gt-logbus/ksr
pwdwam=/gt-logbus/wam
#if [   "$cronday" -gt  "$stopday" ]
#then
#cronmonth=`date +%m`
#else
#cronmonth=`date +%m -d '1 month ago'`
#fi

>/usr/local/shell/check/wam-$awsyear.txt
>/usr/local/shell/check/dwam-$awsyear.txt

cd /data/gt-logbus/dragon-logbus/

#月份
for i in `seq 1 1`
do
  #日期
  for x in `seq  1 7`
  do
#mouth="$i月份"
#day="$i.$x"
ii=`printf "%02d\n" $i`
xx=`printf "%02d\n" $x`
#         mkdir -p  $pwdwam/wam-sync/$awsyear-$ii/$xx
#         cd       $pwdwam/EfunOut/
#         cp *2019-$ii-$xx* $pwdwam/wam-sync/$awsyear-$ii/$xx/
#         aws s3 sync $pwdwam/wam-sync/$awsyear-$ii/  s3://gt-logbus/wam/"$awsyear"-"$ii"/
          ll=`aws s3 ls s3:/$pwdwam/$awsyear-$ii/$xx/ | grep $awsyear-$ii-$xx.tar.gz | wc -l`
          zz=`aws s3 ls s3:/$pwdwam/$awsyear-$ii/$xx/ | grep tar.gz | wc -l`
	  dragon=`ls *$awsyear-$ii-$xx* | wc -l`
#	  ksr1=`aws s3 ls s3:/$pwdksr/$awsyear-$ii/ | grep $awsyear$ii$xx.tar.gz | wc -l`
#	  ksr2=`aws s3 ls s3:/$pwdksr/$awsyear-$ii/ | grep  | wc -l`
	 
#	  echo "$awsyear-$ii-$xx:$ll"  >>/usr/local/shell/check/dwam-$awsyear.txt
#	  echo "$awsyear-$ii-$xx:$zz"  >>/usr/local/shell/check/wam-$awsyear.txt      
          echo  "$awsyear-$ii-$xx:$dragon" >> /usr/local/shell/check/dsf.txt		
#         find  $pwdwam/EfunOut/ -mtime +10 |  xargs rm   
#         find  $pwdwam/wam-sync/$awsyear-$ii/ -mtime +0 |  xargs rm          
  done
done
#echo "$awsyear-$ii-$xx,wam,ok" >>/usr/local/shell/check/logstatus.txt
#curl -d "status=success&date=$awsyear-$cronmonth-$stopday" http://159.138.136.163:8000/api/gamelogs/wam/

