#!/bin/bash
#############################################################
# Description:cdn日志只保留15天                             #
# date:    2019-11-12                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################


#set -o
#aws s3 sync s3://gt-cdn-log/ksr/ /data/efun/adjust/ --exclude "*" --include "xxx*"
#删除cdn日志
deleteday=`date +%Y-%m-%d --date="-15 day"`
aws s3 rm s3://gt-cdn-log/dragon-client/  --recursive --exclude "*" --include "xxx.$deleteday*" 
aws s3 rm s3://gt-cdn-log/dragon-update/  --recursive --exclude "*" --include "xxx.$deleteday*"
aws s3 rm s3://gt-cdn-log/gtyzc/  	  --recursive --exclude "*" --include "xxx.$deleteday*"
aws s3 rm s3://gt-cdn-log/ksr/  	  --recursive --exclude "*" --include "xxx.$deleteday*"  
aws s3 rm s3://gt-cdn-log/wam/            --recursive --exclude "*" --include "xxx.$deleteday*"
#aws s3 rm s3://gt-cdn-log/wst-fight/      --recursive --exclude "*" --include "xxx.$deleteday*"
#aws s3 rm s3://gt-cdn-log/wst-client/     --recursive --exclude "*" --include "xxx.$deleteday*

#删除负载均衡日志
aws s3 rm s3://gt-elblog/ --recursive --exclude "*/*" --include "*$deleteday*"
