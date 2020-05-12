#!/bin/bash
for i in `cat /usr/local/shell/rsa/domian.txt` #读取存储了需要监测的域名的文件
do
    END_TIME=`echo | openssl s_client -servername $i  -connect $i:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' `
    #使用openssl获取域名的证书情况，然后获取其中的到期时间
    END_TIME1=`date +%s -d "$END_TIME"` #将日期转化为时间戳
    NOW_TIME=`date +%s`	
    #NOW_TIME1=`date +%s -d "$NOW_TIME"` #将目前的日期也转化为时间戳
    #echo $END_TIME
    #echo $END_TIME1
    #echo $NOW_TIME
    a=$(($(($END_TIME1 - $NOW_TIME))/(60*60*24))) #到期时间减去目前时间再转化为天数
    echo $a
    if [ $a -lt 15 ]
    then
    /usr/local/shell/itsend.sh     "$i将于$a天之后到期"  "证书到期通知"
    #echo ""$i"将于"$a"天以后到期"|mail -s "证书到期通知" b43ec1e6-00e2-4b8d-b66e-e192e7a154afgt@camail.aiops.com 
            #curl -H "Content-type: application/json" -X POST     -d '{
            #"app": "a40a81f7-eebf-1e25-cd87-f1b210fdbbc1",
            #"eventId": "12345",
            #"eventType": "trigger",
            #"alarmName": "证书到期告警",
            #"entityName": "test",
            #"entityId": "test",
            #"priority": 1,
            #"alarmContent":"'$a','$i'",
            #"details": "test",
            #"contexts": [
            #{
            #   "type": "image",
            #   "src": "http://www.baidu.com/a.png"
            #}]
            #}'    "http://api.aiops.com/alert/api/event"


    fi
done
