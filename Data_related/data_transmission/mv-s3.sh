#!/bin/bash
#############################################################
# Description:mkdir-s3-pwd                                  #
# date:    2019-06-20                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

year=`date +%Y`
cronmonth=`date +%m`
cronday=`date +%d`
startday=`date +%d -d '10 day ago'`
#if [ cronday -eq 1 ]  or [ cronday -eq 2 ]
#then
#cronmonth=`date +%d -d '1 month ago'`

#else
#cronmonth=`date +%d`
#fi



function process(){
trap "exec 1000>&-; exec 1000<&-;exit 0" 2
mkfifo mulfifo
exec 1000<>mulfifo
rm -rf mulfifo
for ((n=1;n<=10;n++))
do
        echo >&1000
done

}



process
#月份
for i in `seq $cronmonth $cronmonth`
do
  for x in `seq $startday $cronday`
  do
ii=`printf "%02d\n" $i`
xx=`printf "%02d\n" $x`
  aws s3  mv s3://gt-logbus/wam/flag_90000_"$year"-"$ii"-"$xx"_"$year"-"$ii"-"$xx".log s3://gt-logbus/wam/"$year"-"$ii"/"$xx"/
  aws s3  mv s3://gt-logbus/wam/flag_90001_"$year"-"$ii"-"$xx"_"$year"-"$ii"-"$xx".log s3://gt-logbus/wam/"$year"-"$ii"/"$xx"/  

  done
done


for i in `seq $cronmonth $cronmonth`
do

  #日期
  for x in `seq $startday $cronday`
  do

    for y in `seq 1 240`
    do
ii=`printf "%02d\n" $i`
xx=`printf "%02d\n" $x`
read -u1000
{
      aws s3  mv s3://gt-logbus/wam/"$y"_"$year"-"$ii"-"$xx".tar.gz s3://gt-logbus/wam/"$year"-"$ii"/"$xx"/
#     aws s3  mv s3://logbus/"$y"_"$year"-"$ii"-"$xx".Resource.tar.gz s3://logbus/"$year"-"$ii"/"$xx"/
      aws s3  mv s3://gt-logbus/wam/flag_"$y"_"$year"-"$ii"-"$xx"_"$year"-"$ii"-"$xx".log s3://gt-logbus/wam/"$year"-"$ii"/"$xx"/
#     aws s3  mv s3://logbus/"$y"_"$year"-"$ii"-"$xx"_new.tar.gz s3://logbus/"$year"-"$ii"/"$xx"/
#     aws s3  mv s3://logbus/flag_90000_"$year"-"$ii"-"$xx"_"$year"-"$ii"-"$xx".log s3://logbus/"$year"-"$ii"/"$xx"/
#     aws s3  mv s3://logbus/flag_90001_"$year"-"$ii"-"$xx"_"$year"-"$ii"-"$xx".log s3://logbus/"$year"-"$ii"/"$xx"/
     echo >&1000
}&
    done
  done
done

wait
exec 1000>&-
exec 1000<&-
exit
