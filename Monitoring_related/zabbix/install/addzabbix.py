#coding:utf-8
# by abel 
# abel_dwh@126.com 
############################################################################
# Description:创建zabbixweb端主机				           #
# date:    2019-11-25                                                      #
# Author:  by abel                                         		   #
# Emain::  abel_dwh@126.com                                		   #
# Explanation：需要修改 host_list.xls  文件            			   #
# For example：python addpython                  		   	   #
############################################################################


import json
import urllib2
from urllib2 import URLError
import sys
import xlrd
reload(sys) 
sys.setdefaultencoding('utf8') 
class ZabbixTools:
    def __init__(self):
        self.url = 'http://xxx/zabbix/api_jsonrpc.php'
        self.header = {"Content-Type":"application/json"}
     
    # 获取主机key
    def user_login(self):
        data = json.dumps({
                           "jsonrpc": "2.0",
                           "method": "user.login",
                           "params": {
                                      "user": "xxx",
                                      "password": "xxx"
                                      },
                           "id": 0
                           })
           
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])
       
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            print "Auth Failed, please Check your name and password:", e.code
        else:
            response = json.loads(result.read())
            result.close()
            self.authID = response['result']
            return self.authID
     
    # 获取hostid
    def host_get(self,hostName):
        data = json.dumps({
                           "jsonrpc":"2.0",
                           "method":"host.get",
                           "params":{
                                     "output":["hostid","name"],
                                     "filter":{"host":hostName}
                                     },
                           "auth":self.user_login(),
                           "id":1,
                           })
           
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            if hasattr(e, 'reason'):
                print 'We failed to reach a server.'
                print 'Reason: ', e.reason
            elif hasattr(e, 'code'):
                print 'The server could not fulfill the request.'
                print 'Error code: ', e.code
        else:
            response = json.loads(result.read())
            result.close()
            print "Number Of %s: " % hostName, len(response['result'])
            lens=len(response['result'])
            if lens > 0:
                return response['result'][0]['name']
            else:
                return ""
      
    # 获取hostgrouid             
    def hostgroup_get(self, hostgroupName):
        data = json.dumps({
                           "jsonrpc":"2.0",
                           "method":"hostgroup.get",
                           "params":{
                                     "output": "extend",
                                     "filter": {
                                                "name": [
                                                         hostgroupName,
                                                         ]
                                                }
                                     },
                           "auth":self.user_login(),
                           "id":1,
                           })
           
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])       
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            print "Error as ", e
        else:
            response = json.loads(result.read())
            result.close()
            lens=len(response['result'])
            if lens > 0:
                self.hostgroupID = response['result'][0]['groupid']
                return response['result'][0]['groupid']
            else:
                print "no GroupGet result"
                return ""
  
    # 获取templateid
    def template_get(self, templateName):
        data = json.dumps({
                           "jsonrpc":"2.0",
                           "method": "template.get",
                           "params": {
                                      "output": "extend",
                                      "filter": {
                                                 "host": [
                                                          templateName,
                                                          ]
                                                 }
                                      },
                           "auth":self.user_login(),
                           "id":1,
                           })
           
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])       
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            print "Error as ", e
        else:
            response = json.loads(result.read())
            result.close()
            # print 'template_get_result:%s' % response['result']
            self.templateID = response['result'][0]['templateid']
            return response['result'][0]['templateid']
    
    # 如主机组不存在则创建hostgroup
    def hostgroup_create(self, hostgroupName):
        
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "hostgroup.create",
            "params": {
                "name": hostgroupName
            },
            "auth": self.user_login(),
            "id": 1
        })
        hostgroupid = self.hostgroup_get(hostgroupName)
        if hostgroupid == '':
            request = urllib2.Request(self.url, data)
            for key in self.header:
                
                request.add_header(key, self.header[key])
            try:
                result = urllib2.urlopen(request)
                print 'result:%s' % result
            except URLError as e:
                print "Error as ", e
            else:
                response = json.loads(result.read())
                result.close()
                return response['result']['groupids']
 
 
    # 创建host
    def host_create(self, hostName,visibleName,hostIp, hostgroupName,hostPort, templateName1):
 
        data = json.dumps({
                           "jsonrpc":"2.0",
                           "method":"host.create",
                           "params":{
                                     "host": hostName,
                                     "name": visibleName,
                                     #"proxy_hostid": self.proxy_get(proxyName),
                                     "interfaces": [
                                                        {
                                                            "type": 1,
                                                            "main": 1,
                                                            "useip": 1,
                                                            "ip": hostIp,
                                                            "dns": "",
                                                            "port": hostPort
                                                        }
                                                    ],
                                    "groups": [
                                                    {
                                                        "groupid": self.hostgroup_get(hostgroupName)
                                                    }
                                               ],
                                    "templates": [
                                                    {
                                                        "templateid": self.template_get(templateName1)
                                                           
                                                    }
                                                  ],
                                     },
                           "auth": self.user_login(),
                           "id":1                  
        })
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])
                
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            print "Error as ", e
        else:
            response = json.loads(result.read())
            result.close()
            print "host : %s is created!   hostid is  %s\n" % (hostip, response['result']['hostids'][0])
            self.hostid = response['result']['hostids']
            return response['result']['hostids']
    
    def host_create_with2templates(self, hostName,visibleName,hostIp, hostgroupName, hostPort,templateName1, templateName2):
        data = json.dumps({
                           "jsonrpc":"2.0",
                           "method":"host.create",
                           "params":{
                                     "host": hostName,
                                     "name": visibleName,
                                     #"proxy_hostid": self.proxy_get(proxyName),
                                     "interfaces": [
                                                        {
                                                            "type": 1,
                                                            "main": 1,
                                                            "useip": 1,
                                                            "ip": hostIp,
                                                            "dns": "",
                                                            "port": hostPort
                                                        }
                                                    ],
                                    "groups": [
                                                    {
                                                        "groupid": self.hostgroup_get(hostgroupName)
                                                    }
                                               ],
                                    "templates": [
                                                    {
                                                        "templateid": self.template_get(templateName1)
                                                           
                                                    },
                                                    {
                                                        "templateid": self.template_get(templateName2)
                                                           
                                                    }
                                                  ],
                                     },
                           "auth": self.user_login(),
                           "id":1                  
        })
        request = urllib2.Request(self.url, data)
        for key in self.header:
            request.add_header(key, self.header[key])
                
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            print "Error as ", e
        else:
            response = json.loads(result.read())
            result.close()
            print "host : %s is created!   hostid is  %s\n" % (hostip, response['result']['hostids'][0])
            self.hostid = response['result']['hostids']
            return response['result']['hostids']
                  
# 程序的入口                
if __name__ == "__main__":
    test = ZabbixTools()
    workbook = xlrd.open_workbook('host_list.xls')
    for row in xrange(workbook.sheets()[0].nrows):
        if row == 0:
                continue
        hostname=workbook.sheets()[0].cell(row,0).value
        visible=workbook.sheets()[0].cell(row,1).value
        hostip=workbook.sheets()[0].cell(row,2).value
        hostgroup=workbook.sheets()[0].cell(row,3).value
        hostport=int(workbook.sheets()[0].cell(row,4).value)
        hosttemp=workbook.sheets()[0].cell(row,5).value
        hosttemp2=workbook.sheets()[0].cell(row,6).value
  
        hostgroup=hostgroup.strip()
        hostgroupid = test.hostgroup_get(hostgroup)
        if hostgroupid == '':
            test.hostgroup_create(hostgroup)
  
        hostnameGet=test.host_get(hostname)
 
        if hostnameGet.strip() != '':
            print "%s have exist! Cannot recreate !\n" % hostnameGet
            continue
        if hostnameGet.strip() == '' and hosttemp != '' and hosttemp2 != '':
            print hostname + ',' + visible + ',' + hostip + ',' + hostgroup + ',' + str(hostport) + ',' + hosttemp + ',' + hosttemp2
            test.host_create_with2templates(hostname,visible,hostip,hostgroup,hostport,hosttemp,hosttemp2)
            continue
 
        if hostnameGet.strip() == '' and hosttemp != '':
            print hostname + ',' + visible + ',' + hostip + ',' + hostgroup + ',' + str(hostport) + ',' + hosttemp
            test.host_create(hostname,visible,hostip,hostgroup,hostport,hosttemp)
