#############################################################
# Description:监控高图sdk进程是否正常,1分钟运行一次            #
# date:    2019-12-25                                       #
# Author:  lintianyang                                      #
# Emain::  lintiany@outlook.com                             #
#############################################################

ps -ef |grep -E 'skynet|rsync-data' |  grep -v grep  | awk '{print $10"_"$12,99}' >/etc/zabbix/shell/check/discoverywstpro.txt



function wstpro_process_discovery () {
UrlFile="/etc/zabbix/shell/check/discoverywstpro.txt"
IFS=$'\n'

WEB_SITE=($(cat $UrlFile|grep -v "^#"))
printf '{\n'
printf '\t"data":[\n'
num=${#WEB_SITE[@]}
for site in ${WEB_SITE[@]}
do
        num=$(( $num - 1 ))
        proname=$(echo $site|awk '{print $1}')
        Tvalue=$(echo $site|awk '{print $2}')
    if [ $num -ne 0 ] ; then
        printf "\t\t{\"{#PRONAME}\":\""${proname}"\",\"{#TVALUE}\":\""${Tvalue}"\"},\n"
    else
                printf "\t\t{\"{#PRONAME}\":\""${proname}"\",\"{#TVALUE}\":\""${Tvalue}"\"}\n"
        printf '\t]\n'
        printf '}\n'
    fi

done
}



function wst_num () {
cat /etc/zabbix/shell/check/discoverywstpro.txt | grep $1 | awk '{print $2}' 
}


case "$1" in
    wstpro_process_discovery)
    wstpro_process_discovery
    ;;
    wst_num)
    wst_num $2 
    ;;
    *)
    echo "Usage:$0 {wstpro_process_discovery|gtsdk_process_discovery [proname}]}"
    ;;
esac
