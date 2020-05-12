```
devops/
├── aws                                  **aws**
│   ├── aws-rds-modify.sh               批量更新aws正式
│   ├── checkphd.sh                     aws健康检查通知
│   ├── cmdb.sh                         各云服cmdb信息调用
│   ├── create-ec2.sh                   批量创建主机
│   ├── restore-s3.sh.sh                批量恢复s3数据
│   └── wst-client-cdn.sh               cdn热更
├── code_release                        **code_release **
│   └── wst_gamecode.sh                 wst游戏代码发布
├── create                              **创建类**
│   ├── gtwst-initialization.sh         wst服务器初始化
│   ├── install-elk.sh                  安装elk
│   ├── jenkins
│   │   ├── addzabbix.py                批量添加web主机信息
│   │   ├── analysiscdn.sh              分析cdn日志
│   │   ├── cloudwatch.sh               批量添加cloudwatch告警
│   │   ├── gtzabbix.sh                 一件安装集成zabbix信息
│   │   └── tiqu-adjust.sh              提取adjust数据
│   ├── jumpserver.sh                   安装jumpserver
│   ├── shenji.sh                       安装审计日志
│   └── smartping.sh                    安装smartping
├── data_related                        **数据类**
│   ├── data_analysis
│   │   ├── analysiscdn.sh              分析cdn日志
│   │   ├── check-gts3.sh               检查数据
│   │   ├── json-csv.sh                 批量json转csv
│   │   ├── tongjidsflog.sh             统计游戏日志是否有问题
│   │   └── tongji.sh                   统计zabbix数据
│   ├── data_extraction
│   │   ├── bigdataksr.sh               批量导入游戏日志
│   │   ├── extract-adjust.sh           提取adjust数据
│   │   ├── extract-mongo.sh            提取mongo数据       
│   │   └── sdinfo.sh                   提取指定info文件
│   ├── data_transmission
│   │   ├── ksr-hourlogbus.sh           备份和检查游戏日志
│   │   ├── mv-s3.sh                    批量转移数据
│   │   └── tongjigamelog.sh            统计数据
│   ├── date_backup
│   │   ├── mysql_rsync_v3.sh           提取mysql数据,并下发到大数据
│   │   └── wam-logbus.sh               备份游戏日志
│   └── date_delete
│       └── delete-awslog.sh            清理过期日志
├── db
│   ├── backup_mysql.sh                 备份mysql
│   ├── mongofull-bak.sh                备份mongo
│   └── mongoinc-bak.sh                 增量备份mongo
├── IT_NETWORK
│   ├── dpkg.sh                         处理dpkg错误
│   ├── ip-api.py                       获取ip信息
│   ├── smbuser.sh                      添加smbuser用户
│   └── speedtest.py                    测带宽
├── Monitoring_related                  **监控类**
│   ├── conf                            **zabbix配置文件**    
│   │   ├── dragon_online.conf
│   │   ├── game_onlines.py
│   │   ├── gt.conf
│   │   ├── gt_memcache.conf
│   │   ├── gt_mongodb.conf
│   │   ├── gt_mysql.conf
│   │   ├── gt_redis.conf
│   │   ├── gtsdk.conf
│   │   ├── httpcode.conf
│   │   ├── ksr_online.conf
│   │   └── wstpro.conf
│   ├── shell                           **zabbix监控脚本**
│   │   ├── check-gtsdkpay.sh
│   │   ├── discovey_wst_proname.sh
│   │   ├── diskname.sh
│   │   ├── displayallports.py
│   │   ├── gt-memcache_status.sh
│   │   ├── gt-mongodb_global.sh
│   │   ├── gt-mongodb_server.sh
│   │   ├── gt-mysql_status.sh
│   │   ├── gt-redis_status.sh
│   │   ├── gt-system_status.sh
│   │   ├── other
│   │   │   ├── checkdisk.sh
│   │   │   └── checkdomain.sh
│   │   ├── wstonline.sh
│   │   └── zabbix-ps.sh
│   └── web_template                    **zabbix模板**
│       ├── discovery_process_templates.xml
│       ├── game_online_templates.xml
│       ├── gt_cpu_templates.xml
│       ├── gt_iops_templates.xml
│       ├── gt_mainserver_templates.xml
│       ├── gt_mongod_templates.xml
│       ├── gt_mysql_templates.xml
│       ├── gt_redis_templates.xml
│       ├── gt_sdk_templates.xml
│       ├── http_status_templates.xml
│       ├── icmp_templates.xml
│       ├── memcache_templates.xml
│       ├── netflow_templates.xml
│       ├── netstat_templates.xml
│       ├── wam_online_templates.xml
│       ├── wam_pay_templates.xml
│       └── wst_online_templates.xml
├── other
│   ├── dingdingtest.py                 发送钉钉信息
│   ├── itsend.sh
│   └── pt-send.py
└── WST
    ├── checkwstlog.sh                  批量检查wst程序日志
    ├── wst_autostart.sh                自动开服
    └── wst-Failover.sh                 故障转移
  
```
