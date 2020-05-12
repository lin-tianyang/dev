#!/usr/bin/env python
#ecoding:utf-8

import urllib, json, sys, os, pickle, time

reload(sys)
sys.setdefaultencoding('utf8')


#手动修改的地方
class global_variable():
    url = "https://dgjq-pay.efunen.com/queryOnLines"
    change_list = {'serverCode':'id', 'onlineCnt':'online', 'serverName':'name'}

#存储缓存的路径，固定的无需修改
path = os.path.abspath(os.path.dirname(__file__))
# filename = os.path.join(path, 'cache_data.pkl')
filename = r'/tmp/cache_data.pkl'



#批量替换函数
def change_string(str, change_list):
    for k in change_list:
        str = str.replace(k,change_list[k])
    return str.replace('&','and')

#从原厂api接口获取数据信息
def api_get():
    result = urllib.urlopen(global_variable.url).read()
    if result:
        #这里必须返回的格式是[{'serverid':'xxx', 'name':'xxx', 'online':111},{'serverid':'xxx', 'name':'xxx', 'online':111}]
        #列表嵌套字典的格式
        #change_string() 方法是做字符串替换命令
        return json.loads(change_string(result, global_variable.change_list))['list']


#整合zabbix自动发现页面（此处无需修改）
def return_zabbix_discovery():
    dev = []
    for data in api_get():
        dev += [{'{#SERVERID}': "%s" % data['id'],'{#NAME}': "%s" % data['name']}]
    print json.dumps({'data':dev}, sort_keys=True, indent=7, ensure_ascii=False,separators=(',',':'))

#将页面获取的信息。转换成键值对
def to_dicts():
    tmp = {}
    for d in api_get():
        tmp['%s' %d['id']] = int(d['online'])
    return tmp
   # return { d['serverid']:d['online'] for d in api_get() }

#pickle导出函数
def pickle_dump(data):
    with file(filename, 'wb') as f:
        pickle.dump(data,f)

#生成缓存文件
#如果检测缓存文件超过指定的时间范围。则报警提醒。缓存更新异常
def update_cache():
    #获取文件的更新时间
    try:
        pickle_dump(to_dicts())
    except:
        print '生成缓存异常'

#pickle导入函数
#读取缓存失败则直接读取原厂页面信息。如果还失败则返回-1
def pickle_load(key):
    file_mtime = int(time.time()) - int(os.stat(filename).st_mtime)
    if file_mtime > 1800:
        return -1
    try:
        with open(filename,'r+') as f:
            data = pickle.load(f)
        return data[key]
    except BaseException,e:
        try:
            return to_dicts()[key]
        except:
            return -2

def main():
    try:
        if sys.argv[1] == 'online':
            #返回自动发现json格式数据
            return_zabbix_discovery()
        elif sys.argv[1] == 'cache':
            #保存缓存
            update_cache()
        elif sys.argv[1] == 'value' and sys.argv[2]:
            #读取缓存。如果读取失败先返回-1
            print pickle_load(sys.argv[2])
        elif sys.argv[1] == '-h' or sys.argv[1] == 'help':
            info = '''
                使用方法：python %s online 显示zabbix自动发现列表
                注意实现：千万不要手动执行 python %s cache 如果这样执行。生成的缓存文件属组为root，zabbix用户无法调用。
                返回值：python %s value id  返回当前获取的值
                ''' %(__file__, __file__, __file__)
            print info
        else:
            print  '''获取执行帮助信息 python %s help''' % __file__
    except BaseException,e:
        print e

if __name__=='__main__':
    main()