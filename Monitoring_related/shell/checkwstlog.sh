#!/bin/bash
#############################################################################
# Description:检查游戏日志（centos7.6）                                     # 
# date: 2019-12-04                                                          #                                                          
# Emain: jarvislin@goatgames.com                                            #                                               
# Explanation：当出现error时打印前后3行,进行邮件加钉钉告警                  #
# For example：/bin/bash  /usr/local/shell/checkwstlog.sh 2>&1 >/dev/null   #                        
#############################################################################
gtyear=`date  +%Y`
gtyears=`date  +%Y -d '1 day ago'`
gtmouth=`date  +%m`
gtmouths=`date  +%m -d '1 day ago'`
stoptime=`date  +%Y-%m-%d" "%H":"%M -d "+8 hour -1 minute"`
startime=`date  +%Y-%m-%d" "%H":"%M -d "+8 hour -3 minute"`
wstname=`hostname`
#Log_directorys="/data/wst/server-pkg/server-group/*/log"
Error_log="/usr/local/shell/check/wsterrorlog"
last_num="/usr/local/shell/check/wstlastnumlog"
wstlogpwd="/data/service/log"
mkdir -p /usr/local/shell/check/wsterrorlog/
mkdir -p /usr/local/shell/check/wstlastnumlog/



cd $wstlogpwd
for wstgamename in `ls $wstlogpwd`
do
    for wstlog in `ls $wstlogpwd/$wstgamename | grep  -Ev "$gtyear|usercnt.log"`
    do
        #如果变量为目录则跳过
        [ -d "$wstlogpwd/$wstgamename/$wstlog" ] && continue
        
        logfilemarkfile="$wstgamename"_"$wstlog"
        
        [ ! -f "$last_num/$logfilemarkfile" ] && echo 1 > $last_num/$logfilemarkfile
        
        last_count=`cat $last_num/$logfilemarkfile`
        
        current_count=`cat $wstlogpwd/$wstgamename/$wstlog | wc -l` 
        
        [ $last_count -eq $current_count ] && echo "`date` $logfile no change" && continue
        #由于日志文件每天都会截断，因此会出现当前行数小于上一次行数的情况，此种情况出现则将上一次行数置1
        [ $last_count -gt $current_count ] && last_count=1
        #截取上一次检查到的行数至当前行数的日志并检索出有ERROR的日志，并重定向到相应的ERROR日志文件
        sed -n "$last_count,$current_count p" $wstlogpwd/$wstgamename/$wstlog | grep -v heartbeat |grep -i ERROR -C 3  >> $Error_log/$logfilemarkfile || echo "`date` $logfile changed but no error"
        #判断ERROR日志是否存在且不为空，不为空则说明有错误日志，继而发送报警信息，报警完成后删除错误日志
        [ -s $Error_log/$logfilemarkfile ]  && python2 /usr/local/shell/wst-send.py "`cat $Error_log/$logfilemarkfile`" "$wstname--$logfilemarkfile"   \
        && echo "`cat $Error_log/$logfilemarkfile`" | mutt -s  "$wstname--$logfilemarkfile"  xxx  


        #结束本次操作之后把当前的行号作为下一次检索的last number
        rm -rf $Error_log/$logfilemarkfile
        echo $current_count > $last_num/$logfilemarkfile
        #python /usr/local/shell/test.py "`cat -n game-chat20191224060136.log | grep error -C 2|head -n 5 `" 123
    done    
done
