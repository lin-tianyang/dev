#!/bin/bash
#############################################################
# Description:wst监控在线人数,1分钟运行一次                 #
# date:    2019-12-25                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

cat /data/service/log/global_wms/usercnt.log |grep -v ts2 | awk -F ',' '{print $2,$3}' |  awk -F  ':' '{print $2,$3}' | awk '{ print $1,$3}' | sed 's/\"//g' >/etc/zabbix/shell/wstonline.txt 
#chmod 777 /data/wst/server-pkg/server-group/tglobal/log/test.log 
#chmod 777 /etc/zabbix/shell/wstonline.txt

UrlFile="/etc/zabbix/shell/wstonline.txt"
IFS=$'\n'

function wst_online_discovery () {
    WEB_SITE=($(cat $UrlFile|grep -v "^#"))
    printf '{\n'
    printf '\t"data":[\n'
    num=${#WEB_SITE[@]}
    for site in ${WEB_SITE[@]}
    do
    num=$(( $num - 1 ))
    gamename=$(echo $site|awk '{print $1}')
    online=$(echo $site|awk '{print $2}')
        if [ $num -ne 0 ] ; then
            printf "\t\t{\"{#GAMENAME}\":\""${gamename}"\",\"{#ONLINE}\":\""${online}"\"},\n"
        else

            printf "\t\t{\"{#GAMENAME}\":\""${gamename}"\",\"{#ONLINE}\":\""${online}"\"}\n"
            printf '\t]\n'
            printf '}\n'
        fi
    done
}


function wst_online_total () {
cat /etc/zabbix/shell/wstonline.txt | grep $1 | awk '{print $2}'
}


case "$1" in
    wst_online_discovery)
        wst_online_discovery
        ;;
    wst_online_total)
        wst_online_total $2 $3
        ;;
    *)
        echo "Usage:$0 {wst_online_discovery|wst_online_total [gamename]}"
        ;;
esac