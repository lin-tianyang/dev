#!/bin/bash
#chmod +x /usr/bin/df /usr/bin/awk /usr/bin/grep
#自动发现以挂载的磁盘分区,不适应所有机器

#diskname=(`df | awk '{ print $1 }' | grep -v tmpfs | grep -v '文件系统' | grep -v '^$'| awk -F '/' '{print $3}'`)
diskname=(`df | awk '{ print $1 }' | grep -Ev 'tmpfs|文件系统|Filesystem|^$'   | awk -F '/' '{print $3}'`)

length=${#diskname[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
     printf '\n\t\t{'
     printf "\"{#DISK}\":\"${diskname[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"
