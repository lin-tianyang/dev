#!/bin/bash
#############################################################
# Description:Monitoring memcache  status                   #
# date:    2019-04-02                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################



if [[ $# == 1 ]];then
    case $1 in
        cache_hit_ratio)           #缓存命中率
            get=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep get_hits | awk  '{print $3}'`
            cmd=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cmd_get | awk   '{print $3}'`
            result=`echo "$get $cmd" | awk '{print (($2/$1)*100)}'`
            echo $result
        ;;
        accepting_conns)           #服务器是否达到过最大连接
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep accepting_conns | awk  '{print $3}'`
            echo $result
        ;;
        bytes)                      #当前存储占用的字节数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep bytes |awk '{print $3}' | awk '{sum += $1};END {print sum}'`
            echo $result
        ;;
        cas_hits)                   #cas命令命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cas_hits | awk '{print $3}'`
            echo $result
        ;;       
        cas_misses)                  #cas命令未命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cas_misses | awk  '{print $3}'`
            echo $result
        ;;          
        cmd_flush)                   #flush命令请求次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cmd_flush | awk  '{print $3}'`
            echo $result
        ;;
        cmd_get)                      #get命令请求次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cmd_get | awk '{print $3}'`
            echo $result
        ;;
        cmd_set)                      #set命令请求次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep cmd_set | awk  '{print $3}'`
            echo $result
        ;;   
        connection_structures)        #Memcached分配的连接结构数量
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep connection_structures | awk  '{print $3}'`
            echo $result
        ;;   
        curr_connections)             #当前连接数量
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep curr_connections | awk '{print $3}'`
            echo $result
        ;; 
        curr_items)                   #当前存储的数据总数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep curr_items | awk  '{print $3}'`
            echo $result
        ;;     
        decr_hits)                   #decr命令命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep decr_hits | awk  '{print $3}'`
            echo $result
        ;; 
        decr_misses)                   #decr命令未命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep decr_misses | awk  '{print $3}'`
            echo $result
        ;;   
        delete_hits)                   #dlete命令命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep delete_hits | awk  '{print $3}'`
            echo $result
        ;; 
        delete_misses)                   #dlete命令未命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep delete_misses | awk  '{print $3}'`
            echo $result
        ;; 
        get_hits)                       #get命令命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep get_hits | awk  '{print $3}'`
            echo $result
        ;; 
        get_misses)                     #get命令未命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep get_misses | awk  '{print $3}'`
            echo $result
        ;; 
        incr_hits)                       #incr命令命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep incr_hits | awk  '{print $3}'`
            echo $result
        ;; 
        incr_misses)                     #incr命令未命中次数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep incr_misses | awk  '{print $3}'`
            echo $result
        ;;
        limit_maxbytes)                   #分配的内存总大小
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep limit_maxbytes | awk  '{print $3}'`
            echo $result
        ;;
        threads)                           #当前线程数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep threads | awk  '{print $3}'`
            echo $result
        ;;
        total_connections)                 #Memcached运行以来连接总数
            result=`printf "stats\r\n" | nc 127.0.0.1 11211 | grep total_connections | awk '{print $3}'`
            echo $result
        ;;

    esac
fi

