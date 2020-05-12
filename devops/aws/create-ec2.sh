#!/bin/bash
#$1=ec2name,$2=ec2,$3=ami-074e2d6769f445be5

#在线扩容
#function expansion(){
#lsblk
#growpart /dev/xvda 1
#resize2fs /dev/xvda1
#yum install epel-release -y
#yum install cloud-utils-growpart -y
#}

#aws ec2 describe-instance-status --profile lundun | grep InstanceId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'
function create-ec2(){
#ec2                 创建主机
#image-id            镜像
#count               数量
#instance-type       实例类型
#subnet-id           子网段
#key-name            秘钥
#security-group-ids  安全组
#DeviceName          磁盘名
#VolumeSize          磁盘大小
>check/awsec2.txt
aws ec2 run-instances \
--image-id $3 \
--count 1 --instance-type $2  \
--subnet-id subnet-025b806193396095e  \
--key-name aws-wst --security-group-ids sg-0f2e4dd67d13520d0 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=wst,Value=$i}]' \
--block-device-mappings file://mapping.json >>check/awsec2.txt

#过滤InstanceId
cat check/awsec2.txt | grep  -i InstanceId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' >>awsid.txt
}


function volume(){
#ec2 创建磁盘
aws ec2 create-volume --size 100 --region us-west-1 --availability-zone us-west-1a --volume-type gp2 >>check/volume.txt
cat check/volume.txt |grep -i volumes | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' >>check/volume1.txt
}

function ip(){
#创建弹性ip-并且指定ip地址
aws ec2 allocate-address   >>check/awsip.txt
cat check/awsip.txt |grep -w PublicIp | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' >>check/awsip1.txt
}

function one(){
#ec3 创建内网ip
aws ec2 create-network-interface --subnet-id subnet-06fd35caf031744fa --description "wam-test" --groups sg-0115cc0fcd6297163 --private-ip-address $ip
#下载rds慢日志
aws rds download-db-log-file-portion --db-instance-identifier ksr-db2 --log-file-name slowquery/mysql-slowquery.log
#连接弹性ip
aws ec2 associate-address --instance-id  i-06da183254829ec5c --public-ip $ip
#释放弹性ip
aws ec2 disassociate-address --public-ip $ip
#回复弹性ip，误删除了一定要快速执行此命令，不然被别人抢走了就找不回了
aws ec2 allocate-address --domain vpc --address $ip
}

#>awsid.txt
>check/volume.txt
>check/volume1.txt
>check/awsip.txt
>check/awsip1.txt
for i in `cat $1`
do 
#create-ec2 $i $2 $3
#volume $i
ip $i
done

for i in `cat awsid.txt`
do
xx=`cat -n awsid.txt | grep $i| awk '{print $1}'`
yy=`sed -n ""$xx"p" check/awsip1.txt` 
zz=`sed -n ""$xx"p" check/volume1.txt`
aws ec2 associate-address --instance-id $i --public-ip $yy
#aws ec2 attach-volume --volume-id $zz --instance-id $i --device /dev/sdb
done