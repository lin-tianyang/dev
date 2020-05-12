#!/bin/bash
#############################################################
# Description:Monitoring mongodb  status                    #
# date:    2019-04-25                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################
mongodpwd=/usr/local/shell/mongod
mkdir -p $mongodpwd

#请填写相关信息
host=`ifconfig | grep inet | head -n1 | awk '{print $2}'`
port="xxx"


if [[ $# == 1 ]];then
    case $1 in        
        myState)                   #当前副本集状态，为1代表为主节点，为2代表为从节点
            result=`echo "rs.status().myState" | mongo  --host $host --port $port --quiet`
            echo $result
        ;;
        extra_info.page_faults)    #页错误总数，当数据库性能不佳、内存限制、或者数据库较大会导致该值增加
            result=`echo "db.serverStatus().extra_info.page_faults" | mongo  --host $host --port $port --quiet`
            echo $result
        ;;
        #连接数和网络相关
        network.bytesIn)           #当前数据库流入数，单位M
            result1=`cat $mongodpwd/bytesIn.txt`
            result=`echo "db.serverStatus().network.bytesIn" | mongo  --host $host --port $port --quiet| awk -F '[(/)]' '{print $2}'` 
            echo $result >$mongodpwd/bytesIn.txt
            echo "$result1 $result" | awk '{print int(($2-$1)/1024/1024)}'
        ;;
        network.bytesOut)          #当前流出数，单位M
            result1=`cat $mongodpwd/bytesOut.txt`
            result=`echo "db.serverStatus().network.bytesOut" | mongo  --host $host --port $port --quiet| awk -F '[(/)]' '{print $2}'`
            echo $result >$mongodpwd/bytesOut.txt
            echo "$result1 $result" | awk '{print int(($2-$1)/1024/1024)}'                        
        ;;        
        connections.available)     #当前可用的连接数，数据库上的连接负载的值，小于100告警
            result=`echo "db.serverStatus().connections.available" | mongo  --host $host --port $port --quiet`
            echo $result
        ;;
        connections.current)       #当前连接数，包括当前的shell会话，副本集成员连接，mongos实例连接
            result=`echo "db.serverStatus().connections.current" | mongo --host $host --port $port --quiet`
            echo $result
        ;;        
        #内存相关
        mem.resident)             #当前数据库进程占用内存情况
            result=`echo "db.serverStatus().mem.resident" | mongo --host $host --port $port --quiet`
            echo $result
        ;;
        mem.virtual)              #当前数据库进程占用虚拟内存的大小     
            result=`echo "db.serverStatus().mem.virtual" | mongo --host $host --port $port --quiet`
            echo $result
        ;;    
        #执行数相关
        opcounters.command)       #mogodb当前总执行语句总数
            result1=`cat $mongodpwd/command.txt`
            result=`echo "db.serverStatus().opcounters.command" | mongo --host $host --port $port --quiet`
            echo $result >$mongodpwd/command.txt
            echo "$result1 $result" | awk '{print int($2-$1)}'
        ;; 
        opcounters.delete)        #mongo_delete当前语句执行数
            result1=`cat $mongodpwd/delete.txt`
            result=`echo "db.serverStatus().opcounters.delete" | mongo --host $host --port $port --quiet`
            echo $result >$mongodpwd/delete.txt
            echo "$result1 $result" | awk '{print int($2-$1)}'
        ;;  
        opcounters.insert)       #mongo_insert当前语句执行数
            result1=`cat $mongodpwd/insert.txt`
            result=`echo "db.serverStatus().opcounters.insert" | mongo --host $host --port $port --quiet`
            echo $result >$mongodpwd/insert.txt
            echo "$result1 $result" | awk '{print int($2-$1)}'
        ;;
        opcounters.query)            #mongo_query当前语句执行数
            result1=`cat $mongodpwd/query.txt`
            result=`echo "db.serverStatus().opcounters.query" | mongo --host $host --port $port --quiet`
            echo $result >$mongodpwd/query.txt
            echo "$result1 $result" | awk '{print int($2-$1)}'
        ;; 
        opcounters.update)        #mongo_update当前语句执行数
            result1=`cat $mongodpwd/update.txt`
            result=`echo "db.serverStatus().opcounters.update" | mongo --host $host --port $port --quiet`
            echo $result >$mongodpwd/update.txt
            echo "$result1 $result" | awk '{print int($2-$1)}'
        ;; 
        #锁相关
        globalLock.currentQueue.readers)    #因读锁而造成排队等待的数量
            result=`echo "db.serverStatus().globalLock.currentQueue.readers" | mongo --host $host --port $port --quiet`
            echo $result
        ;;    
        globalLock.currentQueue.writers)    #因写锁而造成排队等待的数量
            result=`echo "db.serverStatus().globalLock.currentQueue.writers" | mongo --host $host --port $port --quiet`
            echo $result
        ;;     
	optime)
	    tFirst=`echo "db.getReplicationInfo()" | mongo --host $host --port $port | grep tFirst  |  awk -F ':' '{print $2}' | sed 's/\"//g'`
	    tLast=`echo "db.getReplicationInfo()" | mongo --host $host --port $port | grep tLast |  awk -F ':' '{print $2}' | sed 's/\"//g'`
	    echo `date -d "$tFirst" +%s`,`date -d "$tLast" +%s` |  awk -F ',' '{print ($2-$1)/(60*60*24)}' 
	;;
	esac  
fi



