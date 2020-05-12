#!/bin/bash
#############################################################
# Description:Monitoring mysql  status                      #
# date:    2020-02-20                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

#请把账号密码写入/usr/local/zabbix/scripts/.my.cnf 

case $1 in
    Uptime)                 #mysql运行时间
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    status|cut -f2 -d":"|cut -f1 -d"T"`
        echo  $result
    ;;
    Com_update)             #更新的操作次数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_update"|cut -d"|" -f3`
        echo  $result
    ;;
    Slow_queries)           #查询时间超过long_query_time秒的查询的个数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    status |cut -f5 -d":"|cut -f1 -d"O"`
        echo  $result
    ;;
    Com_select)             #mysql查询操作次数   
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_select"|cut -d"|" -f3`
        echo  $result
    ;;
    Com_rollback)           #mysql回滚次数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_rollback"|cut -d"|" -f3`
        echo  $result
    ;;
    Questions)              #已经发送给服务器的查询的个数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    status|cut -f4 -d":"|cut -f1 -d"S"`
        echo  $result
    ;;
    Com_insert)             #mysql插入操作次数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_insert"|cut -d"|" -f3`
        echo  $result
    ;;
    Com_delete)             #mysql删除操作次数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_delete"|cut -d"|" -f3`
        echo  $result
    ;;
    Com_commit)             #mysql删除操作次数       
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_commit"|cut -d"|" -f3`
        echo  $result
    ;;
    Bytes_sent)             #发送给所有客户端的字节数    
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Bytes_sent" |cut -d"|" -f3`
        echo  $result
    ;;
    Bytes_received)         #从所有客户端接收到的字节数
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Bytes_received" |cut -d"|" -f3`
        echo  $result
    ;;
    Com_begin)              #事务开始标记(只能统计显示事务)
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Com_begin"|cut -d"|" -f3`
        echo  $result
    ;;
    Innodb_data_written)    #innodb 数据写
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf    extended-status |grep -w "Innodb_data_written"|cut -d"|" -f3`
        echo  $result
    ;;
    Slave_delay)            #主从延迟
        result=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf    -e 'show slave status\G' |grep -E "Seconds_Behind_Master"|cut -d":" -f2`
        echo  $result
    ;;
    Slave_check)            #主从监控
        result=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf    -e 'show slave status\G' |grep -E 'Slave_IO_Running|Slave_SQL_Running' | grep -i yes |wc -l`
        echo  $result
    ;;
    mysql_cpu)              #mysqlcpu使用率
        pid=`ps -ef | grep mysql | grep  pid  | awk '{print $2}'`
        result=`top -b -n 1 -p $pid | awk '{print $9}' | tail -n 1 | awk '{print int($1)}'`
        echo $result
    ;;
    mysql_mem)              #mysql内存使用率
        pid=`ps -ef | grep mysql | grep  pid  | awk '{print $2}'`
        result=`top -b -n 1 -p $pid | awk '{print $9}' | tail -n 1 | awk '{print int($1)}'`
        echo $result
    ;;
    mysql_lock)             #mysql表锁
        result=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e  "show OPEN TABLES where In_use > 0;" |wc -l`
        lock=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e  "show OPEN TABLES where In_use > 0;" `
        if [ $result -ge 1 ] 
        then
        echo $lock >> /var/log/mysqllock.log
        fi
        echo $result
    ;;
    mysql_listen)           #监控内网端口
        ip=`ifconfig | grep inet | awk '{print $2}' | head -n 1`
        result=`echo "" | telnet $ip 3306  2>/dev/null | grep "]" | wc -l `
        echo $result
    ;;
    mysql_slowlog)          #慢日志查询
        result=`mysqladmin --defaults-file=/usr/local/zabbix/scripts/.my.cnf status | awk -F ':' '{print $5}' | awk '{print $1}'`
        echo $result
    ;;   
    mysql_tps)			   	#mysql_tps
        Com_commit=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e "SHOW GLOBAL STATUS LIKE 'Com_commit';"| grep Com_commit | awk '{print $2}'` 
        Com_rollback=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e "SHOW GLOBAL STATUS LIKE 'Com_rollback';" | grep Com_rollback | awk '{print $2}'`  
        Uptime=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e "SHOW GLOBAL STATUS LIKE 'Uptime';"  | grep Uptime | awk '{print $2}'`
        result=`echo "$Com_commit,$Com_rollback,$Uptime" | awk -F ',' '{ print ($1+$2)/$3}'`
        echo $result
    ;;
    mysql_qps)				#mysql_qps	
        Questions=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e "SHOW GLOBAL STATUS LIKE 'Questions';" | grep Questions | awk '{print $2}'`
        Uptime=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf  -e "SHOW GLOBAL STATUS LIKE 'Uptime'; " | grep Uptime | awk '{print $2}'`
        result=`echo "$Questions,$Uptime" | awk -F ',' '{print $1/$2}'`
        echo $result
    ;;
    mysql_connected)		#mysql连接数	
        Questions=`mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf -e "show status like 'Threads%';"| grep -w Threads_connected | awk '{print $2}'`
        echo $Questions
    ;;

    *)  #················································································································
        echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Innodb_data_written|Slave_delay)"
        ;;
esac

