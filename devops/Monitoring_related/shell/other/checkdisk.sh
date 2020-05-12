#!/bin/bash

disk1=`smartctl -H /dev/sda  | grep -w PASSED  |wc -l`
disk2=`smartctl -H /dev/sdb  | grep -w PASSED  |wc -l`
disk3=`smartctl -H /dev/sdc  | grep -w PASSED  |wc -l`
disk4=`smartctl -H /dev/sdd  | grep -w PASSED  |wc -l`
datedf=`df -h | grep -w data | awk '{ print ($5*100)}'` 
date1df=`df -h | grep -w data1 | awk '{ print ($5*100)}' `

if [ $disk1 -gt 1 ] 
then 
/usr/local/shell/itsend.sh     "共享主机磁盘1有问题请检查"  "警告"
fi

if [ $disk2 -gt 1 ]
then
/usr/local/shell/itsend.sh     "共享主机磁盘2有问题请检查"  "警告"
fi

if [ $disk3 -gt 1 ]
then
/usr/local/shell/itsend.sh     "共享主机磁盘3有问题请检查"   "警告"
fi


if [ $disk4 -gt 1 ]
then
/usr/local/shell/itsend.sh     "共享主机磁盘4有问题请检查"   "警告"
fi


if [ $datedf -gt 9000  ]
then
/usr/local/shell/itsend.sh     "$datedf" "警告"
fi

if [ $date1df -gt 9000 ]
then
/usr/local/shell/itsend.sh     "$date1df" "警告"
fi


