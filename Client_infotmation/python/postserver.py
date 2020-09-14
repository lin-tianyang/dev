#!/usr/bin/env python3

"""
__author__ = "lty"
__version__ = "0.1"
实现不同路径下post请求需求,结合loki做日志分析
"""

from flask import Flask, request, jsonify
import logging
import json
import sys
import hashlib

app = Flask(__name__)
app.debug = True
#hashlib.md5(b'123').hexdigest()
#print (hashlib.md5(poi.encode(encoding='GB2312')).hexdigest())



# 实现功能1，打印玩家错误日志,并且根据sign字段做md5效验
@app.route('/client_error/', methods=['post'])
def client_error():
    if not request.data:  # 检测是否有数据
        return ('fail')
        student = request.data.decode('utf-8')
        # 获取到POST过来的数据,转化成字典
        student_json = json.loads(student)
        
        #md5效验
        pipei = "kurolog" + student_json['time']
        kuromd5 = (hashlib.md5(pipei.encode(encoding='GB2312')).hexdigest())
        client_sige = student_json['sign']
        #当md5值匹配时,将内容打印到指定log
        if kuromd5 == client_sige:
            clientlog = open('/data/log/client_log/client_error.log', mode='a', encoding='utf-8')
            print(student_json, file=clientlog)
            return jsonify(student_json)
        #反之什么都不做
        else:
            print ("do nothing")



# 实现功能2，打印玩家完整信息,并且根据device_id和time值输出到日志
# 打印玩家错误日志
@app.route('/playerlog/', methods=['post'])
def playerlog():
    if not request.data:  #检测是否有数据
        return ('fail')
    student = request.data.decode('utf-8')
    # 获取到POST过来的数据,转化成字典
    student_json = json.loads(student)
    #获取字段指定value值
    player_name = student_json['device_id']
    player_time = student_json['time']
    mylog = open('/data/log/player_log/'+player_name+player_time+'.log', mode='a', encoding='utf-8')
    #将内容打印到指定log
    print(student, file=mylog)
    #print(type(student), file=mylog)
    #print(type(student_json), file=mylog)
    #print(list(student_json.keys()), file=mylog)
    #print(client_name, file=mylog)
    # 返回JSON数据
    return jsonify(student_json)




if __name__ == '__main__':
    app.run(host='192.168.41.202', port=8000)
    # 这里指定了地址和端口号。