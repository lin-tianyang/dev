#!/usr/bin/python
#coding=utf-8
import commands

##########返回命令执行结果
def getComStr(comand):
    try:
        stat, proStr = commands.getstatusoutput(comand)
    except:
        print "command %s execute failed, exit" % comand
    #将字符串转化成列表
    #proList = proStr.split("\n")
    return proStr

##########获取系统服务名称和监听端口
def filterList():
    tmpStr = getComStr("netstat -tpln | grep -Evw 'tcp6|rsync|rsync'")
    tmpList = tmpStr.split("\n")
    del tmpList[0:2]
    newList = []
    for i in tmpList:
        val = i.split()
        del val[0:3]
        del val[1:3]
        #提取端口号
        valTmp = val[0].split(":")
        val[0] = valTmp[1]
        #提取服务名称
        valTmp = val[1].split("/")
        val[1] = valTmp[-1]
        if val[1] != '-' and val not in newList:
            newList.append(val)
    return newList

def main():
    netInfo = filterList()
    #格式化成适合zabbix lld的json数据
    json_data = "{\n" + "\t" + '"data":[' + "\n"
    #print netInfo
    for net in netInfo:
        if net != netInfo[-1]:
    	    json_data = json_data + "\t\t" + "{" + "\n" + "\t\t\t" + '"{#PPORT}":"' + str(net[0]) + "\",\n" + "\t\t\t" + '"{#PNAME}":"' + str(net[1]) + "\"},\n"
        else:
   	     json_data = json_data + "\t\t" + "{" + "\n" + "\t\t\t" + '"{#PPORT}":"' + str(net[0]) + "\",\n" + "\t\t\t" + '"{#PNAME}":"' + str(net[1]) + "\"}]}"
    print json_data

if __name__ == "__main__":
    main()
