#!/bin/bash

db="goatgames"
sqltime=`date +%F" "%H:%M:%S`
startime=`date +%F" "%H:%M:%S -d '5 minute ago'`

#支付
#curl -s http://xxx/monitor/payment?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g' > check/check_payment.txt
#curl -s http://xxx/monitor/payment?startTime=2019-12-28 | awk -F ':' '{print $3}' | awk -F ','  '{print $1}' 
#登录 

#mkdir -p /etc/zabbix/shell/check
chown zabbix:zabbix -R /etc/zabbix/shell/check
case  $1 in 
iospay)   	   #ios支付
	mysql  --defaults-file=/usr/local/zabbix/scripts/.my.cnf -N -D$db -e  "select order_id,created_at from orders where created_at>='$startime' AND created_at<'$sqltime'  and status='complete' and belong='ios' limit 2;" > /etc/zabbix/shell/check/ios-check.txt
	cat /etc/zabbix/shell/check/ios-check.txt | wc -l
;;

androidpay)    #and支付
	mysql --defaults-file=/usr/local/zabbix/scripts/.my.cnf -N -D$db  -e "select order_id,created_at from orders where created_at>='$startime' AND created_at<'$sqltime'  and status='complete' and belong='android' limit 2;" >/etc/zabbix/shell/check/and-check.txt
	cat /etc/zabbix/shell/check/and-check.txt | wc -l
;;

gtpayment)       #支付
	gtpayment_now=`curl -s http://xxx/monitor/payment?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g'` 
	gtpayment_bef=`cat /etc/zabbix/shell/check/check_payment.txt`
	gtpayment_status=`curl -s http://xxx/monitor/payment?startTime=2019-12-28 | awk -F ':' '{print $3}' | awk -F ','  '{print $1}'`
	if [ $gtpayment_status -eq 200 ]
	then
		result=`echo "$gtpayment_now,$gtpayment_bef" | awk -F ',' '{print int($1-$2)}'`
		echo $result
		curl -s http://xxx/monitor/payment?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g'  >/etc/zabbix/shell/check/check_payment.txt
	else
		python2 /etc/zabbix/shell/test.py "`curl -s http://xxx/monitor/payment?startTime=2019-12-28`"	"支付接口可能有问题"
	fi
;;

gtregister)    #注册
	gtregister_now=`curl -s http://xxx/monitor/register?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g'` 
	gtregister_bef=`cat /etc/zabbix/shell/check/check_register.txt`
	gtregister_status=`curl -s http://xxx/monitor/register?startTime=2019-12-28 | awk -F ':' '{print $3}' | awk -F ','  '{print $1}'`
	if [ $gtregister_status -eq 200 ]
	then
		result=`echo "$gtregister_now,$gtregister_bef" | awk -F ',' '{print int($1-$2)}'`
		echo $result
		curl -s http://xxx/monitor/register?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g' > /etc/zabbix/shell/check/check_register.txt
	else
		python2 /etc/zabbix/shell/test.py "`curl -s http://xxx/monitor/register?startTime=2019-12-28`"  "注册接口可能有问题"
	fi
;;

gtlogin)       #登录
	gtlogin_now=`curl -s http://xxx/monitor/login?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g'` 
	gtlogin_bef=`cat /etc/zabbix/shell/check/check_login.txt`
	gtlogin_status=`curl -s http://xxx/monitor/login?startTime=2019-12-28 | awk -F ':' '{print $3}' | awk -F ','  '{print $1}'`
	if [ $gtlogin_status -eq 200 ]
	then
		result=`echo "$gtlogin_now,$gtlogin_bef" | awk -F ',' '{print int($1-$2)}'`
		echo $result
		curl -s http://xxx/monitor/login?startTime=2019-12-28 | awk -F ':' '{print $5}' |  sed 's/\}//g'  >/etc/zabbix/shell/check/check_login.txt
	else
		python2 /etc/zabbix/shell/test.py "`curl -s http://xxx/monitor/login?startTime=2019-12-28`"	"登录接口可能有问题"
	fi
;;
esac
