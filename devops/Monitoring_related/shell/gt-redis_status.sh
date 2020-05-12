#!/bin/bash
#############################################################
# Description:Monitoring redis  status                      #
# date:    2019-04-02                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

#需要知道host，port，pass，cli-pwd
REDISCLI="/usr/bin/redis-cli"
HOST="xxx"
PORT="xxx"
PASS="xxx"
#$REDISCLI -h $HOST -a $PASS -p $PORT info 

if [[ $# == 1 ]];then
    case $1 in
        total_connections_received)         #redis总接收数
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  | grep -w "total_connections_received" | awk -F':' '{print $2}'`
            echo $result
        ;;
        rdb_last_save_time)                 #redis最后存储时间
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Persistence | grep -w "rdb_last_save_time" | awk -F':' '{print $2}'`
            echo $result
        ;;
        keys)                               #redis当前key数量
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Keyspace | grep keys | awk -F ',' '{print $1}'  | awk -F '=' '{sum += $2};END {print sum}'`
            echo $result
        ;;
        role)                               #redis 角色
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Replication  | grep -w "role" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        host)                               #redis masterip
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Replication  | grep -w "master_host" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        expired_keys)                       #redis 过期key数量
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "expired_keys" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        keyspace_misses)                       #redis key失败次数
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "keyspace_misses" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        keyspace_hits)                       #redis key成功次数
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "keyspace_hits" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        evicted_keys)                       #redis 回收key
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "evicted_keys" | awk -F ':' '{print $2}'`
            echo $result
        ;;       
        total_commands_processed)           #redis 回收key
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "total_commands_processed" | awk -F ':' '{print $2}'`
            echo $result
        ;;        
        errlog)                             #监控redis错误日志
            result=`cat /var/log/redis/redis-server.log | grep -i err | wc -l`
            echo $result
        ;;
        curl)                               #redis curl计划任务
            result=`ps -ef  | grep curl | grep redis | grep -v grep  | wc -l`
            echo $result
        ;;
        ops)                                #redis ops
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep  "ops" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        instantaneous_ops_per_sec)          #redis瞬间流量
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info  Stats | grep -w "instantaneous_ops_per_sec" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        blocked_clients)                    #等待阻塞
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info clients | grep -w "blocked_clients" | awk -F':' '{print $2}'`
            echo $result
        ;;
        connected_clients)                   #客户端连接数
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info clients | grep -w "connected_clients" | awk -F':' '{print $2}'`
            echo $result
        ;;

        sync)                               #从服务器是否在与主服务器进行同步
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Replication  | grep -w "master_sync_in_progress" | awk -F ':' '{print $2}'`
            echo $result
        ;;        
        connected_slave)                    #从库数量
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Replication  | grep  "connected_slave" | awk -F ':' '{print $2}'`
            echo $result
        ;;
        used_memory_peak)                   #内存消耗峰值
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep -w "used_memory_peak" | awk -F':' '{print $2}'`
            echo $result
        ;;
        used_memory)                       #使用的内存
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep -w "used_memory" | awk -F':' '{print $2}'`
            echo $result
        ;;
        used_memory_rss)                   #返回redis已分配的内存总量
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep -w "used_memory_rss" | awk -F':' '{print $2}'`
            echo $result
        ;;       
        uptime_in_seconds)                 #启动时长
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info Server | grep -w "uptime_in_seconds" | awk -F':' '{print $2}'`
            echo $result
        ;;
        used_cpu_sys)                      #将所有redis主进程在核心态所占用的CPU时求和累计起来
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info cpu | grep -w "used_cpu_sys" | awk -F':' '{print $2}'`
            echo $result
        ;;
        used_cpu_user)                     #将所有redis主进程在用户态所占用的CPU时求和累计起来
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info cpu | grep -w "used_cpu_user" | awk -F':' '{print $2}'`
            echo $result
        ;;
        used_cpu_sys_children)             #将后台进程在核心态所占用的CPU时求和累计起来
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info cpu | grep -w "used_cpu_sys_children" | awk -F':' '{print $2}'`
            echo $result
        ;;
	maxmemory)                     #reid neicun
            result=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep maxmemory | awk -F':' '{print $2}'`
            echo $result
        ;;
        mem_fragmentation_ratio)           #内存碎片
            p=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep -w "used_memory" | awk -F':' '{print $2}'`
            pt=`$REDISCLI -h $HOST -a $PASS -p $PORT info memory | grep -w "used_memory_rss" | awk -F':' '{print $2}'`
            result=`echo "$p $pt" | awk '{print int(($2/$1)*100)}'`
            echo $result
        ;;
        redis_keyspace_hits)           #redis 命中率
            hits=`$REDISCLI -h $HOST -a $PASS -p $PORT info Stats | grep -w "keyspace_hits" | awk -F':' '{print $2}'`
            miss=`$REDISCLI -h $HOST -a $PASS -p $PORT info Stats | grep -w "keyspace_misses" | awk -F':' '{print $2}'`
            result=`echo "$hits $miss" | awk '{print 	int($1/($1+$2)*100)}'`
            echo $result
        ;;
    esac
fi
