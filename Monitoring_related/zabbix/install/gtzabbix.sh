#!/bin/bash
#########################################################################################################
# Description:集成zabbix安装                                                                            #
# date:    2020-04-10                                                                                   #
# Author:  lintianyang                                                                                  #
# Emain::  lintiany@outlook.com                                                                         #
# Explanation：$1==host文件 $2==port $3==密钥 $4==zabbix-port $5==version $6==groupname $7==username    #
# For example：/bin/bash install-zabbix.sh host 22 rsa/ksr   10050   7 test centos                      #
#########################################################################################################



#ssh -p $2  -o "StrictHostKeyChecking no" $i  "rpm -Uvh https://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.25-1.el6.x86_64.rpm"
rsafile=`echo $3| awk -F '/' '{print $NF}'`


if [ $5 == 7 ]
then 

function install-gt(){
cp    /usr/local/shell/test/zabbix_agentd.conf /usr/local/shell/test/zabbix_agentd.conf-bak
sed -i "s:ListenPort=10050:ListenPort=$4:g" /usr/local/shell/test/zabbix_agentd.conf-bak
sed -i "s:Hostname=Zabbix server:Hostname=$i:g" /usr/local/shell/test/zabbix_agentd.conf-bak
$args << eeooff
yum -y install sysstat
mkdir -p /etc/zabbix/shell
chmod +s /usr/bin/netstat /usr/bin/cat  /usr/sbin/ss
rpm -Uvh https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-agent-3.0.25-1.el7.x86_64.rpm
rm -f /etc/zabbix/zabbix_agentd.d/*.conf
mkdir -p /usr/local/zabbix/scripts/
mkdir -p /usr/local/shell
systemctl enable zabbix-agent
eeooff
$arps  /usr/local/shell/test/zabbix_agentd.conf-bak  $i:/etc/zabbix/zabbix_agentd.conf
$arps /usr/local/shell/zabbix/gt.conf $i:/etc/zabbix/zabbix_agentd.d/
$arps /usr/local/shell/zabbix/gt-system_status.sh $i:/etc/zabbix/shell
$arps /usr/local/shell/zabbix/displayallports.py    $i:/etc/zabbix/shell
$arps  /usr/local/shell/zabbix/diskname.sh $i:/etc/zabbix/shell
$args "chmod -R +x /etc/zabbix/shell /usr/local/shell"
$args "systemctl restart zabbix-agent"
result=`$args  "netstat -tnlp |grep 10050| wc -l && rpm -qa | grep sysstat |wc -l"`
echo $result
}

else
function install-gt(){
iptables -F
cp    /usr/local/shell/test/zabbix_agentd.conf /usr/local/shell/test/zabbix_agentd.conf-bak
sed -i "s:10050:$4:g" /usr/local/shell/test/zabbix_agentd.conf-bak
sed -i "s:Hostname=Zabbix server:Hostname=$i:g" /usr/local/shell/test/zabbix_agentd.conf-bak
$args << eeooff
yum -y install sysstat
mkdir -p /etc/zabbix/shell
mkdir -p /usr/local/shell
chmod +s /bin/netstat /bin/cat /usr/sbin/ss
rpm -Uvh https://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.25-1.el6.x86_64.rpm
rm -f   /etc/zabbix/shell/*
rm -f   /etc/zabbix/zabbix_agentd.conf
rm -f   /etc/zabbix/zabbix_agentd.d/*.conf
chkconfig  zabbix-agent on
eeooff
$arps  /usr/local/shell/test/zabbix_agentd.conf-bak  $i:/etc/zabbix/
$arps  /usr/local/shell/zabbix/gt.conf $i:/etc/zabbix/zabbix_agentd.d/
$arps  /usr/local/shell/zabbix/gt-system_status.sh $i:/etc/zabbix/shell
$arps  /usr/local/shell/zabbix/port_discovery.py    $i:/etc/zabbix/shell
$arps  /usr/local/shell/zabbix/diskname.sh $i:/etc/zabbix/shell
$args "chmod -R +x /etc/zabbix/shell /usr/local/shell"
$args "mv /etc/zabbix/zabbix_agentd.conf-bak /etc/zabbix/zabbix_agentd.conf"
$args "service zabbix-agent restart"
echo $i
result=`$args  "netstat -tnlp |grep $4| wc -l && rpm -qa | grep sysstat |wc -l"`
echo $i,$result  >> /usr/local/shell/check/zabbix.txt
}
fi



function install-mysql(){
$arps  /usr/local/shell/zabbix/gt-mysql_status.sh  $i:/etc/zabbix/shell/
$arps /usr/local/shell/zabbix/gt_mysql.conf $i:/etc/zabbix/zabbix_agentd.d/
$args "chmod -R +x /etc/zabbix/shell"
if [ $5 == 7 ]
then
	$args "systemctl restart zabbix-agent"
else
	$args "service restart zabbix-agent"
fi

zabbix_get -s $i -k gt.mysql.info[Uptime]
}

function install-redis(){
$arps  /usr/local/shell/zabbix/gt-redis_status.sh  $i:/etc/zabbix/shell/
$arps /usr/local/shell/zabbix/gt_redis.conf $i:/etc/zabbix/zabbix_agentd.d/
$args "chmod -R +x /etc/zabbix/shell"
if [ $5 == 7 ]
then
	$args "systemctl restart zabbix-agent"
else
	$args "service restart zabbix-agent"
fi
zabbix_get -s $i -k gt.redis.info[total_connections_received]
}

function install-mongodb(){
$arps  /usr/local/shell/zabbix/gt-mongodb_status.sh  $i:/etc/zabbix/shell/
$arps /usr/local/shell/zabbix/gt_mongodb.conf $i:/etc/zabbix/zabbix_agentd.d/
$args "chmod -R +x /etc/zabbix/shell"
if [ $5 == 7 ]
then
	$args "systemctl restart zabbix-agent"
else
	$args "service restart zabbix-agent"
fi
zabbix_get -s $i -k gt.mongodb.info[connections.available]
}

function install-memcache(){
$arps  /usr/local/shell/zabbix/gt-memcache_status.sh  $i:/etc/zabbix/shell/
$arps /usr/local/shell/zabbix/gt_memcache.conf $i:/etc/zabbix/zabbix_agentd.d/
$args "chmod -R +x /etc/zabbix/shell"
if [ $5 == 7 ]
then
	$args "systemctl restart zabbix-agent"
else
	$args "service restart zabbix-agent"
fi
zabbix_get -s $i -k gt.memcache.info[total_connections]
}

function rsa(){

username=`echo $7`
if  [[ $username == root	]]
then
	eho 123
else
	if [[ "$rsafile" =~ "pem" ]]
	then
$centosargs << eeooff
	sudo -s
	sudo mkdir  -p /root/.ssh
	cat /home/$username/.ssh/authorized_keys  >/root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
eeooff
	else
	echo  hello
	fi
fi

}

function addzabbix(){

cd /usr/local/shell/jenkins/
export LANG='zh_CN.utf8'
export LANG="zh_CN.UTF-8"
>host_list.xls
>host_list.csv

var_port=$4
var_name="$6"
cat $1  | awk  -F ',' -v var=$var_port -v var_name=$var_name '{print $1","$2","$1","var_name","var",""gt_for linked Efun Linux Templates"",""Network Interface for amazon_shengtang"}' >>host_list.csv
sed -i '1i\hostname,visible,hostip,hostgroup,hostport,hosttemp,hosttemp2'  host_list.csv
unix2dos host_list.csv
ssconvert host_list.csv  host_list.xls 
python addzabbix.py
}



#如果是root用户不需要监控redis,mysql等这样就够了,需要监控打开对应函数即可,如果用户是centos,请开启rsa和清除公钥信息
for i in `cat $1 | awk -F ',' '{print $1}'`
do

centosargs="ssh -o StrictHostKeyChecking=no -p $2 -i $3 $7@$i"
if [[ "$rsafile" =~ "pem" ]]
then
args="ssh -o StrictHostKeyChecking=no -p $2 -i $3 root@$i"
arps="scp -o StrictHostKeyChecking=no -P $2 -i $3"
else
args="sshpass -p $3 ssh -o StrictHostKeyChecking=no -p $2 root@$i"
arps="sshpass -p $3 scp -o StrictHostKeyChecking=no -P $2"
fi

rsa  $i $2 $3 $4 $5 $6 $7 
install-gt $i $2 $3 $4 $5
#install-mysql $i $2 $3 $4
#install-redis $i $2 $3 $4
#install-mongodb $i $2 $3 $4
#install-memcache $i $2 $3 $4
done



addzabbix $1 $2 $3 $4 $5 $6 $7
