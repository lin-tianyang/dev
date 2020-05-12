#!/bin/bash
mkdir -p /data/opt
cd /data/opt
git clone https://github.com/gy-games/smartping.git
wget https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
tar zxvf go1.8.linux-amd64.tar.gz -C /usr/local
mkdir -p /var/opt/wwwroot/goblog
echo "export GOROOT=/usr/local/go"  >>/etc/profile
echo "export GOBIN=$GOROOT/bin"     >>/etc/profile
echo "export PATH=$PATH:$GOBIN"     >>/etc/profile
echo "export GOPATH=/var/opt/wwwroot/goblin"  >>/etc/profile
source /etc/profile
cd smartping
chmod 755 control
./control build
