#!/bin/bash

set -o pipefail
user=`cat usersmb.txt | grep -v grep | grep $1 | wc -l`
if [ $user -eq 0 ]
then


user=$1
passwd=`cat /dev/urandom |tr -dc A-Za-z0-9 | head -c10`
useradd $1
usermod -g gtms $1
echo -e "$passwd\n$passwd" | smbpasswd -s -a  $user
echo 用户:$user 密码:$passwd >>/usr/local/shell/usersmb.txt
#sed -i  'N;276a'$user',\' /etc/samba/smb.conf

else 
echo "$1 is already exists"

fi


