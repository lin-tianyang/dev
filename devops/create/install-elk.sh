#!/bin/bash
curl -sL https://rpm.nodesource.com/setup_8.x | sudo bash -
yum install -y nodejs 
wget https://github.com/mobz/elasticsearch-head/archive/master.zip

wget https://artifacts.elastic.co/packages/7.x/yum/7.2.0/kibana-7.2.0-x86_64.rpm
wget https://artifacts.elastic.co/packages/7.x/yum/7.2.0/elasticsearch-7.2.0-x86_64.rpm
wget  https://artifacts.elastic.co/packages/7.x/yum/7.2.0/logstash-7.2.0.rpm
wget  https://artifacts.elastic.co/packages/7.x/yum/7.2.0/filebeat-7.2.0-x86_64.rpm
wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
rpm -i kibana-7.2.0-x86_64.rpm
rpm -i elasticsearch-7.2.0-x86_64.rpm
rpm -i logstash-7.2.0.rpm
rpm -i filebeat-7.2.0-x86_64.rpm
systemctl stop elasticsearch 
systemctl start kibana
systemctl start logstash




