#!/bin/bash
#############################################################################
# Description:wst自动脚本                                                   # 
# date: 2020-05-06                                                          #                                                          
# Emain: jarvislin@goatgames.com                                            #                                               
# Explanation：重新调整wst自动开服策略,新增白名单,多配置文件动态调节        #
# For example：在定时任务中自动运行脚本，达到要求就开服                     #                        
#############################################################################
#New=新服  Normal=正常  Crowded=拥挤 Unopened=维护
#判断条件1:registerCnt接近upper_limit_number  2:达到upper_limit_time 时间 
#created_at-配置文件时间，real_time-真实开服时间-即脚本修改状态时间         
#code=进程管理服名  name=游戏服名   servername=name
#php artisan migrate:refresh   清理wst后台数据(删库操作)

wstpwd="/usr/local/shell/wst"
wstcheck="/usr/local/shell/wst/check"
wstconfig="/usr/local/shell/wst/conf"
gameid=`cat $wstcheck/game_id.txt`
newgameid=`echo $gameid | awk '{print $1+1}'`
client_json="ca_server_list.json"


#读取对应的信息
mysql -uxxx -p'xxx' -hxxx -Dxxx  -N -e "select code,name,upper_limit_number,upper_limit_time from servers where code=$gameid;" > $wstcheck/gtsdk.txt
game_name=`cat $wstcheck/gtsdk.txt  | awk  '{print $2}'`
ssh -pxxx yunwei@xxx "cat /data/service/log/global/usercnt.log | grep -w $game_name" >$wstcheck/wstonline.txt



#匹配2边注册数
gtsdk_register=`cat $wstcheck/gtsdk.txt | awk '{print $3}'`
gtwst_register=`cat $wstcheck/wstonline.txt |  awk -F ',' '{print $4}'  | awk -F ':' '{print $2}'`
crete_register=`echo "$gtsdk_register $gtwst_register" |  awk '{ print int($1-$2)}'`


#匹配2边时间参数
gtsdk_limit_time=`cat $wstcheck/gtsdk.txt  | awk '{print $4}'`
ngtsdk_limit_time=`date +%s -d "$gtsdk_limit_time"`
nowtime=`date +%s`
wststarttime=`echo "$ngtsdk_limit_time $nowtime" |  awk '{ print int($1-$2)}'`
realtime=`date "+%Y-%m-%d %H:%M:%S"`


#找到对应配置文件online,和status位置
wststatusnb=`cat $wstcheck/wstserver.txt  | grep -w  $gameid | awk -F ',' '{print $4}'`
wstonlinenb=`cat $wstcheck/wstserver.txt  | grep -w  $gameid |awk -F ',' '{print $5}' | sed 's/\ //g'`
serverconfig=`cat $wstcheck/wstserver.txt | grep -w  $gameid | awk -F ',' '{print $3}'`

newstatusnb=`cat  $wstcheck/wstserver.txt | grep -w  $newgameid | awk -F ',' '{print $4}'`
newonlinenb=`cat  $wstcheck/wstserver.txt | grep -w  $newgameid | awk -F ',' '{print $5}'`
newserverconfig=`cat $wstcheck/wstserver.txt | grep -w  $newgameid | awk -F ',' '{print $3}'` 

#wstonser=`cat $wstcheck/wstserver.txt  | grep -w online | grep -w $wstonlinenb | wc -l`
#wstqstaser=`cat $wstcheck/wstserver.txt | grep -w status | grep -w $wststatusnb | wc -l`
#echo "name:$i,crete_register:$crete_register,wststarttime:$wststarttime,wstqstaser:$wstqstaser,wststatusnb:$wststatusnb,wstonlinenb:$wstonlinenb" >$wstcheck/wstcheck.txt

#判断是否达到条件
if [[ $crete_register  -lt 100  ]] || [[ $wststarttime -lt 600  ]]  
then
        #判断是否是online和status字段
       # if  [[ $wstonser -eq 1  ]] && [[ $wstqstaser -eq 1 ]]
       # then
                #修改旧服状态为正常
                sed -i ""$wststatusnb"s/New/Normal/" $wstconfig/$serverconfig 
                sed -i ""$wstonlinenb"s/false/true/" $wstconfig/$serverconfig
                

                #修改新服的online状态,修改status状态,记录开服名,上传开服时间,只有1个新服存在 
                sed -i ""$newstatusnb"s/Unopened/New/" $wstconfig/$newserverconfig
                sed -i ""$newonlinenb"s/false/true/" $wstconfig/$newserverconfig
                
                
                #记录开服ID
                echo $newgameid >$wstcheck/game_id.txt
                上传开服时间到高图后台
				xxx
                
                #生成客户端文件,备份旧文件,并上传到cdn
                python $wstpwd/gen_serverlist.py online $wstconfig/*.json  > $wstcheck/$client_json
                cp /data/gtcdn/wst/wst-clinet-cdn/web-json/$client_json  $wstcheck/$client_json-$realtime
                rsync -avz   $wstcheck/$client_json   /data/gtcdn/wst/wst-clinet-cdn/web-json/$client_json            
                /bin/bash    /usr/local/shell/wst-client-cdn.sh
                #钉钉通知开服时间
                python /usr/local/shell/wst/wst-send.py  "开服时间为$realtime,详细信息请查看邮件"   "WST-$game_name已经自动开服"
                #echo "$game_name已经自动开服,开服时间为$realtime," | mutt -s "`curl -S https://xxx/web-json/$client_json`" xxx
                #邮箱通知开服
				echo -e "WST详细开服状态为\n`curl -s https://xxx/web-json/$client_json`" | mutt -s "WST-$game_nam已经自动 开服,开服时间为$realtime GMT0" xxx
                #添加白名单
                python $wstpwd/import-whitelist.py  conf/wst-g2config.json  https://xxx/web-json/$client_json $wstpwd/whitelist.json
                #将更新的文件，分发到对应的服务器
                #for i in `cat /usr/local/shell/wst/ip.txt`
                #do
                #        scp -P 61618  $wstconfig/*.json  yunwei@$i:/data/wst/server-pkg/
                #done
fi
                



                #电话通知开服
                #curl -H "Content-type: application/json" -X POST     -d '{
                #        "app": "xxx",
                #        "eventId": "12345",
                #        "eventType": "trigger",
                ##        "alarmName": "数据库可能存在问题",
                #        "entityName": "gtwst",
                #        "priority": 1,
                #        "alarmContent":"'WST-$i以自动开服','开服时间为$realtime'"
                #        }'    "http://xxx/alert/api/event"
       

     #   else
                #钉钉告警
               # python $wstshell/wst-send.py  "自动开服可能存在问题"   "请运维同学马上查看"
                                #电话告警
               #         curl -H "Content-type: application/json" -X POST     -d '{
               #         "app": "xxx",
               #         "eventId": "12345",
               #         "eventType": "trigger",
               #         "alarmName": "wst开服可能存在问题",
               #         "entityName": "gtwst",
               #         "priority": 1,
               #         "alarmContent":"'WST-$i未自动开服','开服时间为$realtime'"
               #         }'    "http://xxx/alert/api/event"
     #   fi
#else
                #打印，没开服时候的条件
#        echo "$i,$realtime,没有达到开服条件" >>$wstcheck/wstcheck.txt
#fi


