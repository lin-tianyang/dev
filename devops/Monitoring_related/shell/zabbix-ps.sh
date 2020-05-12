#!/bin/bash
proarray=($(find /var/run/ -name "*.pid"  2> /dev/null||egrep -v '(rpc|php_daemon|haldaemon|irqbalance|console-kit-daemon)' |awk -F'/' '{print $NF}'|awk -F'.' '{print $1}'))    # 排除不监控的服务

length=${#proarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
printf "\t"
printf '\n\t\t{'
printf "\"{#PRO_NAME}\":\"iptables\"}"       #必须要添加的iptables
printf  ","
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf "\"{#PRO_NAME}\":\"${proarray[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"
