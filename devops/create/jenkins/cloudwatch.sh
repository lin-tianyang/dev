#!/bin/bash
#############################################################################
# Description:创建aws云告警，不同区域对应不同配置文件                       #
# date:    2019-11-25                                                       #
# Author:  lintianyang                                                      #
# Emain::  jarvislin@goatgames.com                                          #
# Explanation：$1==host文件 $2==主题 $3==区域配置文件    $4开启对应参数     #
# For example：/bin/bash  cloudwatch.sh  awscloud xx lundun  ec2-status     #
#############################################################################
#1.怎么获取host文件
#获取实例信息，用于下面跑脚本
#aws ec2 describe-instance-status --profile lundun | grep InstanceId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'

#获取rds主库信息
#aws rds describe-db-instances --profile lundun | grep ReadReplicaSourceDBInstanceIdentifier | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'
#获取rds所有信息
#aws rds describe-db-instances --profile lundun | grep -w DBInstanceIdentifier | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'

#获取redis,memcache信息
#aws elasticache describe-cache-clusters | grep CacheClusterId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'

#2.主题说明
xxx

#3.区域说明
#us-west-1  加利福利亚  eu-west-2 伦敦
#cat /root/.aws/config 查看对应配置文件

#4.参数说明
#alter-memcached         memcached告警相关
#alter-redis             redis告警相关
#alter-db                rds告警相关   
#ec2-status              ec2状态告警相关
#alter-ApplicationELB    旧负载器告警相关
#alter-ELB               新负载器告警相关

#5.cdn相关告警，需要到弗吉尼亚区域设置，因为数量比较少，没有加入到脚本中


#创建db告警参数，参数可以根据实际调整，因为aws没有宕机告警,剩余空间和cpu使用率将缺失的数据作为不良处理，出现告警可能为实例宕机
function alter-db() {
#db剩余空间小于20G
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-FreeStorageSpace 小于20G" --alarm-description "$i-FreeStorageSpace 小于20G" --metric-name FreeStorageSpace --namespace AWS/RDS  --treat-missing-data breaching --statistic Average --period 60 --threshold 20480000000 --comparison-operator LessThanThreshold  --dimensions  "Name=DBInstanceIdentifier,Value=$i"  --evaluation-periods 3 --alarm-actions $2
#db剩余内存间小于512M
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-FreeableMemory 小于512M" --alarm-description "$i-FreeableMemory 小于512M" --metric-name FreeableMemory --namespace AWS/RDS --statistic Average --period 60 --threshold   512000000.0 --comparison-operator LessThanThreshold  --dimensions  "Name=DBInstanceIdentifier,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#DBcpu使用率大于80
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-CPUUtilization 使用率大于80" --alarm-description "$i-CPUUtilization 使用率大于80" --metric-name CPUUtilization --namespace AWS/RDS --treat-missing-data breaching --statistic Average --period 60 --threshold 80 --comparison-operator GreaterThanThreshold  --dimensions "Name=DBInstanceIdentifier,Value=$i" --evaluation-periods 3  --alarm-actions $2
#db交互分区使用超过200M
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-SwapUsage 超过200M" --alarm-description "$i-SwapUsage 超过200M" --metric-name SwapUsage --namespace AWS/RDS --statistic Average --period 60 --threshold 204800000.0 --comparison-operator GreaterThanThreshold  --dimensions "Name=DBInstanceIdentifier,Value=$i" --evaluation-periods 2  --alarm-actions $2
#db DatabaseConnections 连接数大于1000
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-DatabaseConnections 连接数大于1000" --alarm-description "$i-DatabaseConnections 连接数大于1000" --metric-name DatabaseConnections --namespace AWS/RDS --statistic Average --period 60 --threshold 1000 --comparison-operator GreaterThanThreshold  --dimensions "Name=DBInstanceIdentifier,Value=$i" --evaluation-periods 2 --alarm-actions $2
#db 未完成的io请求数  大于50
aws cloudwatch put-metric-alarm --alarm-name --profile $3 "$i-未完成的io请求数  大于50" --alarm-description "$i-未完成的io请求数  大于50" --metric-name DiskQueueDepth --namespace AWS/RDS --statistic Average --period 60 --threshold 50 --comparison-operator GreaterThanThreshold  --dimensions "Name=DBInstanceIdentifier,Value=$i" --evaluation-periods 2  --alarm-actions $2
}

#创建ec2状态告警（重要！每台机器必须添加，用于快速恢复故障机器,不然可能存在一直不恢复情况)
function ec2-status() {
#状态失败，重启实例
aws cloudwatch put-metric-alarm --profile $3 --alarm-name  "$i-StatusCheckFailed" --alarm-description "$i-StatusCheckFailed" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Maximum --period 60 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=$i" --evaluation-periods 3  --alarm-actions $2
#实例失败,恢复实例
aws cloudwatch put-metric-alarm --profile $3 --alarm-name  "$i-StatusCheckFailed_System" --alarm-description "$i-StatusCheckFailed_System" --metric-name StatusCheckFailed_System --namespace AWS/EC2 --statistic Maximum --period 60   --threshold 2 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$i" --evaluation-periods 2  --alarm-actions $2
}

#创建redis告警，参数可以根据实际调整,因为aws没有宕机告警,使用内存和cpu使用率将缺失的数据作为不良处理，出现告警可能为实例宕机
function alter-redis(){
#使用的内存大于4G
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i--BytesUsedForCache 大于4G" --alarm-description "$i--BytesUsedForCache 大于4G" --metric-name BytesUsedForCache --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 4096000000.0 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 3 --alarm-actions $2
#剩余内存小于2048M
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i-FreeableFreeableMemory 小于2048M" --alarm-description "$i-FreeableMemory 小于2048M" --metric-name FreeableMemory --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 2048000000.0 --comparison-operator LessThanOrEqualToThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 3 --alarm-actions $2
#CPu  大于80
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i-CPUUtilization 大于80" --alarm-description "$i-CPUUtilization  大于80" --metric-name CPUUtilization --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 80 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#移出大于1
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i-Evictions 大于1" --alarm-description "$i-Evictions 大于1" --metric-name Evictions --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#交互分区大于1K
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i-SwapUsage 大于1k" --alarm-description "$i-SwapUsage 大于1k" --metric-name SwapUsage --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1024.0 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#连接数大于1000
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "redis-$i-CurrConnections  大于 1000" --alarm-description "$i-CurrConnections  大于1000" --metric-name CurrConnections --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1000.0 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
}

#创建memcache告警，参数可以根据实际调整,因为aws没有宕机告警,使用内存和cpu使用率将缺失的数据作为不良处理，出现告警可能为实例宕机
function alter-memcached() {
#使用的内存大于10G
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-BytesUsedForCacheItems 大于10G" --alarm-description "$i-BytesUsedForCacheItems 大于10G" --metric-name BytesUsedForCacheItems --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 10240000000.0 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#剩余内存小于2G
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-FreeableFreeableMemory 小于2G" --alarm-description "$i-FreeableMemory 小于2G" --metric-name FreeableMemory --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 2048000000.0 --comparison-operator LessThanOrEqualToThreshold  --treat-missing-data breaching  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#CPu  大于80
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-CPUUtilization 大于80" --alarm-description "$i-CPUUtilization  大于80" --metric-name CPUUtilization --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 80 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#移出大于1
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-Evictions 大于1" --alarm-description "$i-Evictions 大于1" --metric-name Evictions --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#交互分区大于1K
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-SwapUsage 大于1k" --alarm-description "$i-SwapUsage 大于1k" --metric-name SwapUsage --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1024.0 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#连接数大于1000
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "memcache-$i-CurrConnections  大于 1000" --alarm-description "$i-CurrConnections  大于1000" --metric-name CurrConnections --namespace AWS/ElastiCache --statistic Average --period 60 --threshold 1000.0 --comparison-operator GreaterThanThreshold  --dimensions  "Name=CacheClusterId,Value=$i"  --evaluation-periods 2 --alarm-actions $2
} 

#创建ApplicationELB告警，参数可以根据实际调整,因为aws没有宕机告警,不健康主机和延迟将缺失的数据作为不良处理，出现告警可能为实例宕机
function alter-ApplicationELB() {
#TargetResponseTime    延时时间大于1秒
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-RequestCount 小于1" --alarm-description "$i-RequestCount 小于1" --metric-name RequestCount --namespace AWS/ApplicationELB --statistic Average --period 60 --threshold 150 --comparison-operator LessThanOrEqualToThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancer,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#UnHealthyHostCount    不健康主机大于1
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-RequestCount 小于1" --alarm-description "$i-RequestCount 小于1" --metric-name RequestCount --namespace AWS/ApplicationELB --statistic Average --period 60 --threshold 150 --comparison-operator LessThanOrEqualToThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancer,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#ActiveConnectionCount  激活连接小于100
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-RequestCount 小于1" --alarm-description "$i-RequestCount 小于1" --metric-name RequestCount --namespace AWS/ApplicationELB --statistic Average --period 60 --threshold 150 --comparison-operator LessThanOrEqualToThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancer,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#RequestCount           连接小于100
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-RequestCount 小于1" --alarm-description "$i-RequestCount 小于1" --metric-name RequestCount --namespace AWS/ApplicationELB --statistic Average --period 60 --threshold 150 --comparison-operator LessThanOrEqualToThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancer,Value=$i"  --evaluation-periods 2 --alarm-actions $2
}


#创建AELB告警，参数可以根据实际调整,因为aws没有宕机告警,不健康主机和延迟将缺失的数据作为不良处理，出现告警可能为实例宕机
function alter-ELB(){
#UnHealthyHostCount   不健康的主机大于1
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-UnHealthyHostCount 大于1" --alarm-description "$i-UnHealthyHostCount 大于1" --metric-name UnHealthyHostCount --namespace AWS/ELB --statistic Average --period 60 --threshold 1 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancerName,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#Latency              负载到主机延迟大于1s 
aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-Latency 大于1" --alarm-description "$i-Latency 大于1" --metric-name Latency --namespace AWS/ELB --statistic Average --period 60 --threshold 1 --comparison-operator GreaterThanThreshold --treat-missing-data breaching --dimensions  "Name=LoadBalancerName,Value=$i"  --evaluation-periods 2 --alarm-actions $2
#RequestCount         请求数小于200
#aws cloudwatch put-metric-alarm --profile $3 --alarm-name "$i-RequestCount 小于200" --alarm-description "$i-RequestCount 大于200" --metric-name RequestCount --namespace AWS/ELB --statistic Sum --period 60 --threshold 1000 --comparison-operator LessThanOrEqualToThreshold  --dimensions  "Name=LoadBalancerName,Value=$i"  --evaluation-periods 2 --alarm-actions $2
}

#创建告警,请开启对应函数
for i in `cat $1`
do
  case $4 in
    alter-memcached)
    alter-memcached $i $2 $3
    ;;
    alter-redis)
    alter-redis $i $2 $3
    ;;
    alter-db)
    alter-db $i $2  $3
    ;;
    ec2-status)
        ec2-status $i $2 $3
        ;;
    alter-ApplicationELB)
    alter-ApplicationELB $i $2 $3
    ;;
    alter-ELB)
    alter-ELB $i $2 $3
    ;;
  esac
done
