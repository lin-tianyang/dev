# loki



## 介绍


`Loki 是一个水平可扩展，高可用性，多租户日志聚合系统,灵感来自 Prometheus ，其设计非常经济高效，易于操作。它不索引日志的内容，而是为每个日志流设置一组标签。Golang開發`


## 组件


Grafana Loki 包括3个主要的组件：Promtail、Loki 和 Grafana（简称 PLG）

---

**Promtail**  是用来将容器日志发送到 Loki 或者 Grafana 服务上的日志收集工具，该工具主要包括发现采集目标以及给日志流添加上 Label 标签，然后发送给 Loki，另外 Promtail 的服务发现是基于 Prometheus 的服务发现机制实现的。


**Loki**  是一个受 Prometheus 启发的可以水平扩展、高可用以及支持多租户的日志聚合系统，使用了和 Prometheus 相同的服务发现机制，将标签添加到日志流中而不是构建全文索引。正因为如此，从 Promtail 接收到的日志和应用的 metrics 指标就具有相同的标签集。所以，它不仅提供了更好的日志和指标之间的上下文切换，还避免了对日志进行全文索引。


**Grafana**  是一个用于监控和可视化观测的开源平台，支持非常丰富的数据源，在 Loki 技术栈中它专门用来展示来自 Prometheus 和 Loki 等数据源的时间序列数据。此外，还允许我们进行查询、可视化、报警等操作，可以用于创建、探索和共享数据 Dashboard，鼓励数据驱动的文化。`


## 功能
### 探索出来的初步功能
```bash
1.自定义分组
可以根据配置文件来实现自定义分组(例:可以把多台服务器的相同日志放到同一组)
2. 多条件查询
可以根据主机ip,自定义分组,日志名等进行自由组合查询
3. 支持正则表达式
可以在配置文件中,配置正则表达式,然后图像中就只显示匹配的日志内容
4. 支持自定义时间查询
在页面选定指定的时间即可
5. 支持查看指定日志等级 
info,error 等日志分类,也可以在配置文件中定义查看指定类型
6.比较友好的小功能 
流媒体模式查看,统计去重数,指定查看行数，分页等功能
```


### 优点
对比elk:简单好用,上手快,可以满足日常日志查询需求,对硬件资源的需求小
### 缺点
产品比较新,文档比较少,基本只能读官方文档, 功能没有elk丰富,运维其他人员对elk更熟悉一点
## 安装部署


- 下载服务端
curl -O -L "[https://github.com/grafana/loki/releases/download/v1.5.0/loki-linux-amd64.zip](https://github.com/grafana/loki/releases/download/v1.5.0/loki-linux-amd64.zip)"
- 客户端
curl -O -l "[https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip](https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip)"
curl -O -l "[https://github.com/grafana/loki/releases/download/v1.5.0/promtail-windows-amd64.zip](https://github.com/grafana/loki/releases/download/v1.5.0/promtail-windows-amd64.zip)"
- grafana
wget [https://dl.grafana.com/oss/release/grafana-7.1.1-1.x86_64.rpm](https://dl.grafana.com/oss/release/grafana-7.1.1-1.x86_64.rpm)
rpm -ivh grafana-7.1.1-1.x86_64.rpm
- 运行
nohup /opt/loki/loki-linux-amd64 -config.file=/opt/loki/loki-config.yaml > /var/log/loki.log 2>&1 &
nohup /opt/loki/promtail-linux-amd64 -config.file=/opt/loki/promtail-22.yaml > promtail_2.log 2>&1 &
/bin/systemctl daemon-reload
/bin/systemctl enable grafana-server.service
/bin/systemctl restart grafana-server

      windows 
.\promtail-windows-amd64.exe --config.file=promtail-local-config.yaml 

- 补充

      后续如果采用loki,会编写批量部署脚本,并对进程进行监控和自动拉起服务
## 
## 配置文件示例
### 服务端  loki-config.yaml
```
auth_enabled: false
server:
  http_listen_port: 3100 
ingester:
  lifecycler:
    address: 0.0.0.0
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s
  max_transfer_retries: 0 
schema_config:
  configs:
    - from: 2020-07-27
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        #每张表的时间范围 6天
        period: 144h
      chunks:
        period: 144h 
storage_config:
#流文件存储地址
  boltdb:
    directory: /data/loki/index
#索引存储地址
  filesystem:
    directory: /data/loki/chunks 
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 144h 
chunk_store_config:
 #最大可查询历史日期 90天
 max_look_back_period: 2160h 
#表的保留期90天
table_manager:
  retention_deletes_enabled: true
  retention_period: 2160h
```
### 客户端 promtail-local-config.yaml
```
server:
  http_listen_port: 9080
  grpc_listen_port: 0
 
positions:
  filename: /tmp/positions.yaml
 
clients:
  - url: http://localhost:3100/loki/api/v1/push
 
scrape_configs:
  - job_name: journal
    journal:
      max_age: 12h
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
  - job_name: system
    pipeline_stages:
    static_configs:
    - labels:
       job: varlogs
       host: 2.2.2.21
       __path__: /var/log/messages
  - job_name: biz001
    pipeline_stages:
    - match:
       selector: '{app="test"}'
       stages:
       - regex:
          expression: '.*level=(?P<level>[a-zA-Z]+).*ts=(?P<timestamp>[T\d-:.Z]*).*component=(?P<component>[a-zA-Z]+)'
       - labels:
          level:
          component:
          ts:
          timestrap:
    static_configs:
    - labels:
       job: biz001
       app: test
       node: 001
       host: localhost
       __path__: /alertmgr/dingtalk/nohup.out
```


## 使用说明
### 简单查询说明

---

![简单查询说明.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596009852029-3f4f6b14-c317-4138-8b90-c11bf0705052.jpeg#align=left&display=inline&height=1000&margin=%5Bobject%20Object%5D&name=%E7%AE%80%E5%8D%95%E6%9F%A5%E8%AF%A2%E8%AF%B4%E6%98%8E.jpg&originHeight=1000&originWidth=2141&size=124606&status=done&style=none&width=2141)


### 多条件查询+正则表达式（Logql)

---

### 可以根据标签,host,logname等+正则表达式做各种复杂查询(当然不建议经常做很大范围的查询,大范围查询会比较吃机器资源)


![多条件加正则表达式.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596009908242-2b7c6122-f8e3-4894-8828-5f2421223ebd.jpeg#align=left&display=inline&height=883&margin=%5Bobject%20Object%5D&name=%E5%A4%9A%E6%9D%A1%E4%BB%B6%E5%8A%A0%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F.jpg&originHeight=883&originWidth=2068&size=151920&status=done&style=none&width=2068)![多条件查询.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596009993093-32ac5734-c8d9-4a75-bd94-20bd3bcae82d.jpeg#align=left&display=inline&height=498&margin=%5Bobject%20Object%5D&name=%E5%A4%9A%E6%9D%A1%E4%BB%B6%E6%9F%A5%E8%AF%A2.jpg&originHeight=498&originWidth=957&size=54831&status=done&style=none&width=957)
多条件可以通过  ,  进行连接, 将命令合并到一行.
![image.png](https://cdn.nlark.com/yuque/0/2020/png/1847847/1596010268500-bf6f5fd2-d69e-4b28-9582-3f9e146e154f.png#align=left&display=inline&height=334&margin=%5Bobject%20Object%5D&name=image.png&originHeight=667&originWidth=1633&size=92114&status=done&style=none&width=816.5)


### 保存常用命令

---

 点击 Query history,点击星号，在Starred页面即可看到保存的命令,方便下次直接调用


![收集常用命令.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596010365003-2979ecfa-7d32-4b41-b0ca-ba515f95bcd5.jpeg#align=left&display=inline&height=411&margin=%5Bobject%20Object%5D&name=%E6%94%B6%E9%9B%86%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4.jpg&originHeight=411&originWidth=2082&size=36207&status=done&style=none&width=2082)![展示常用命令.jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596010372795-593ee19a-3342-4aa5-bec9-60533c125a6a.jpeg#align=left&display=inline&height=333&margin=%5Bobject%20Object%5D&name=%E5%B1%95%E7%A4%BA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4.jpg&originHeight=333&originWidth=2048&size=23409&status=done&style=none&width=2048)


### 小bug

---

  在windows 选择filename时, 会因为路径问题不识别,加上双斜杠即可正常展示.大家将常用命令进行保存,可以比较好的规避这个问题.
![1596009269(1).jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596010796370-0c851773-da49-4e71-9df6-b2b6cb68f5e9.jpeg#align=left&display=inline&height=669&margin=%5Bobject%20Object%5D&name=1596009269%281%29.jpg&originHeight=669&originWidth=2110&size=120574&status=done&style=none&width=2110)![1596009229(1).jpg](https://cdn.nlark.com/yuque/0/2020/jpeg/1847847/1596010807146-d2b62e1e-9091-4c44-a4c5-de16805ca123.jpeg#align=left&display=inline&height=1047&margin=%5Bobject%20Object%5D&name=1596009229%281%29.jpg&originHeight=1047&originWidth=2071&size=89047&status=done&style=none&width=2071)
### 正则表达式(Logql)

---

常用命令

- `=`: exactly equal.
- `!=`: not equal.
- `=~`: regex matches.
- `!~`: regex does not match. 



- 示例: 匹配有this关键字的日志

 {job="test2",host="2.2.2.21"} |= "this"    
![image.png](https://cdn.nlark.com/yuque/0/2020/png/1847847/1596011136531-30706f74-5734-44f4-aa96-a800ec31f135.png#align=left&display=inline&height=321&margin=%5Bobject%20Object%5D&name=image.png&originHeight=641&originWidth=1280&size=55094&status=done&style=none&width=640)


详解文档
[https://github.com/grafana/loki/blob/master/docs/sources/logql/_index.md](https://github.com/grafana/loki/blob/master/docs/sources/logql/_index.md)


## demo

---

目前部署在虚拟机中,大家可以简单的体验下
账号:kuro_code
密码:kuro123456
[http://192.168.41.202:3000/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22,%7B%7D,%7B%22ui%22:%5Btrue,true,true,%22none%22%5D%7D%5D](http://192.168.41.202:3000/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22,%7B%7D,%7B%22ui%22:%5Btrue,true,true,%22none%22%5D%7D%5D)

---

#### 自定义日志
在我的电脑输入  ftp://192.168.41.202/upload
即可在loki 和elk 2个demo中查看自行上传的日志
![image.png](https://cdn.nlark.com/yuque/0/2020/png/1847847/1596087872646-bde7b305-f3af-481a-97f8-871d0b9a374e.png#align=left&display=inline&height=269&margin=%5Bobject%20Object%5D&name=image.png&originHeight=537&originWidth=1069&size=53577&status=done&style=none&width=534.5)






