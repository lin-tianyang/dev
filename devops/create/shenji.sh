#!/bin/bash
#############################################################
# Description:centos7安装审计日志，定时传回来               #
# date:    2019-06-14                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
# Explanation：$1==host文件  $2==prot   $3==秘钥            #
# For example：/bin/bash shenji.sh host 22 ksr.pem          #
#############################################################

#只适用于新机器
lujin="/usr/local/shell"
txtpwd="$lujin/test"
DATE=$(date +%Y%m%d)
prot=$2
args="ssh -p $2 $i"
log="/data/shenji/log"

#cp  /root/.ssh/authorized_keys /root/.ssh/authorized_keys-bak-"$data"
#scp  $txtpwd/profile $i:/etc/profile
#scp  $txtpwd/lsyncd.conf  $i:/etc/
#strings /dev/urandom |tr -dc A-Za-z0-9 | head -c20; echo



function bak(){

        $args "cp /etc/profile /etc/profile-"$DATA"-bak"
}

function chushu(){
rm -f $txtpwd/source
cp   $txtpwd/shenji.log $txtpwd/source
chmod  0600 $txtpwd/passwd
sed -i "s:usermonitor.log:$i-shenji.log:g" $txtpwd/source
$args "cp /etc/profile /etc/profile-bak"
#$args ">/etc/profile"
$args "cat /etc/profile | grep shenji  || cat source >> /etc/profile"
#$args  "/bin/bash /root/chmod.sh"
}

function shenji(){     
      $args << eeooff
        cd /root       
        systemctl enable sshd
        rm -rf /data/shenji/log/
        mkdir -p   /data/shenji/log/
        mkdir -p   /usr/local/shell
        mv  /root/*.sh  /usr/local/shell
        touch /data/shenji/log/$i-shenji.log
        chmod  777 /data/shenji/log/$i-shenji.log
        source /etc/profile
        chmod 600 /etc/rsyncd.passwd
        crontab -l >> cron-bak
        crontab -l >> cronshenji | cat cronshenji | sort | uniq >>cronshenji1
        crontab -l | grep rsync.sh || crontab cronshenji1        
eeooff

}

function check(){
echo "###############$i#############"
sleep 1
$args "crontab -l"
#$args "tail -n 2 /etc/profile"
$args "ls -l /data/shenji/log"
}







>check.txt
for i in `cat $1`
do
args="ssh -p $2 $i -i $3"
chushu $i
scp -P $2  -i $3 $txtpwd/rsync.sh  $i:/root
scp -P $2  -i $3 $txtpwd/source $i:/root
scp -P $2  -i $3 $txtpwd/cronshenji $i:/root
scp -P $2  -i $3 $txtpwd/passwd  $i:/etc/rsyncd.passwd
scp -P $2  -i $3 $txtpwd/checkssh.sh $i:/root
shenji $i
check  $i   >> check.txt
     
done
