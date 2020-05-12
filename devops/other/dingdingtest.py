#!/usr/bin/python
# -*- coding: utf-8 -*-
import requests
import json
import sys
import os

#import logging 

headers = {'Content-Type': 'application/json;charset=utf-8'}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=xxx"

#logging.basicConfig(level=logging.DEBUG,  
#                    format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',  
#                    datefmt='%a, %d %b %Y %H:%M:%S',  
#                    filename='/tmp/test.log',  
#                    filemode='w')  
  


json_text= {

    "actionCard": {
    	"title": "test", 
        "text": "代码变动通知",

        "btns": [
            {
                "title": "代码发布", 
                "actionURL": "curl -X POST http://gt.jenkins.com/generic-webhook-trigger/invoke?token=test"
            }, 
            {
                "title": "查看代码", 
                "actionURL": "http://gt.jenkins.com"
            }
        ]    	
    }, 
    "msgtype": "actionCard"

}
   print (response.json())
 
# encoding:utf-8
import requests

access_token = 'KwGgyPHBKIUN4hdtG1kLIjUd'
url = 'https://aip.baidubce.com/rpc/2.0/unit/bot/chat?access_token=KwGgyPHBKIUN4hdtG1kLIjUd' + access_token
post_data = "{\"bot_session\":\"\",\"log_id\":\"7758521\",\"request\":{\"bernard_level\":1,\"client_session\":\"{\\\"client_results\\\":\\\"\\\", \\\"candidate_options\\\":[]}\",\"query\":\"你好\",\"query_info\":{\"asr_candidates\":[],\"source\":\"KEYBOARD\",\"type\":\"TEXT\"},\"updates\":\"\",\"user_id\":\"88888\"},\"bot_id\":\"1057\",\"version\":\"2.0\"}"
headers = {'content-type': 'application/x-www-form-urlencoded'}
response = requests.post(url, data=post_data, headers=headers)
if response:
    print (response.json())

