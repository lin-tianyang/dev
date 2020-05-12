#!/bin/bash 

function SendMessageToDingding(){ 
    Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=xxx" 
    # 发送钉钉消息
    curl "${Dingding_Url}" -H 'Content-Type: application/json' -d" 
    {
        \"actionCard\": {
            \"title\": \"$1\", 
            \"text\": \"$2\", 
            \"hideAvatar\": \"0\", 
            \"btnOrientation\": \"0\", 
            \"btns\": [
                {
                    \"title\": \"$1\", 
                    \"actionURL\": \"\"
                }
            ]
        }, 
        \"msgtype\": \"actionCard\"
    }"
} 

Subject="$1" 

Body="$2"



SendMessageToDingding $Subject $Body 
