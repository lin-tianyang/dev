#!/bin/bash

xxip=xxx
wstendtime=`date  +%Y-%m-%d"T"%H":"%M":"00`
wststarttime=`date  +%Y-%m-%d"T"%H":"%M":"00 -d '-2 min'`
释放连接弹性ip
aws ec2 associate-address --instance-id  i-06da183254829ec5c --public-ip $xxip
aws ec2 disassociate-address --public-ip $xxip
释放连接内网ip
aws ec2 attach-network-interface --network-interface-id eni-0db0c72c7bec5ef03 --instance-id i-065d38c95984c8105 --device-index 2
aws ec2 detach-network-interface --attachment-id eni-attach-0180430c5f4f0d85b
#获得实例状态
checkstatus=`aws cloudwatch get-metric-statistics --metric-name StatusCheckFailed --start-time $wststartime --end-time $wstendtime \
--period 60 --namespace AWS/EC2 --statistics Maximum --dimensions Name=InstanceId,Value=i-065d38c95984c8105 | grep  -i Maximum  \
 | awk -F ':' '{print $2}'  | sed 's/\,//g' | awk -F ':' '{sum+=$1} END {print sum}'`

if [ $checkstatus -gt 1 ]
then
aws ec2 disassociate-address --public-ip $xxip
aws ec2 associate-address --instance-id  i-06da183254829ec5c --public-ip $xxip
aws ec2 detach-network-interface --attachment-id eni-attach-0180430c5f4f0d85b
aws ec2 attach-network-interface --network-interface-id eni-0db0c72c7bec5ef03 --instance-id i-065d38c95984c8105 --device-index 2
#python2 /usr/local/shell/test.py   "$wstendtime:$checkstatus"   "请注意以启动故障转移" 
fi	
