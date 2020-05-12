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
  

def msg(text, subject):
    json_text= {
        "actionCard": {
            "title": subject,
            "text": text,
            "hideAvatar": "0",
            "btnOrientation": "0",
            "btns": [
                {
                    "title": subject[:50],
                    "actionURL": ""
                }
            ]
        },
        "msgtype": "actionCard"
    }

    print(requests.post(api_url,json.dumps(json_text),headers=headers).content)


if __name__ == '__main__':
    text = sys.argv[1]
    text = text.replace("\n", "\r")
    subject = sys.argv[2]
    msg(text, subject)
