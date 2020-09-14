#!/bin/bash
#aws 
#加利福尼亚     us-west-1
#伦敦           eu-west-2
#宁夏           cn-northwest-1

#腾讯云
#法兰克福       eu-frankfurt-1
#莫斯科         eu-moscow-1

#阿里云
#新加坡         ap-southeast-1
#弗吉尼亚       us-east-1
#法兰克福       eu-central-1
#深圳           cn-shenzhen

#华为云
#香港           ap-southeast-1

#!/bin/bash
#aws  cmdb相关
aws_ec2)
aws ec2 describe-instances --profile $1 --query 'Reservations[].Instances[].{name:Tags[?Key==`Name`]|[0].Value,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,Type:InstanceType,ID:InstanceId,zone:Placement.AvailabilityZone,time:LaunchTime}'  --output table | grep -v DescribeInstances  > /var/www/gtshare/data/gt/files/devops/cmdb/aws_$1_ec2.md


aws_rds)
aws rds describe-db-instances --profile lundun  --query 'DBInstances[].{name:DBInstanceIdentifier,type:DBInstanceClass,Address:Endpoint.Address,time:InstanceCreateTime,Zone:AvailabilityZone}' --output table

aws_memcache)
aws elasticache describe-cache-clusters --profile default --query 'CacheClusters[].{name:CacheClusterId,Engine:Engine,Version:EngineVersion,time:CacheClusterCreateTime}[?Engine==`memcached`]'  --output table | grep -v DescribeCacheClusters

aws_redis)
aws elasticache describe-cache-clusters --profile jz --query 'CacheClusters[].{name:CacheClusterId,Engine:Engine,Version:EngineVersion,time:CacheClusterCreateTime,type:CacheNodeType}' --output table | grep -v DescribeCacheClusters 

#阿里云cmdb相关
echo "instance_name,type,instanceId,publicip,Privateip,zone,keyname,Osname,time"
aliyun ecs DescribeInstances  --RegionId cn-shenzhen | jq '.Instances.Instance[] | {name:.InstanceName, Type:.InstanceTypeFamily, ID:.InstanceId ,PublicIp:.PublicIpAddress.IpAddress[] ,PrivateIp:.NetworkInterfaces.NetworkInterface[].PrimaryIpAddress ,zone:.ZoneId ,OSNAME:.OSName ,time:.StartTime}' | jq  -s  "sort_by(.StartTime) | .[]"  | jq -r '[.[]] | @csv'


#腾讯云服cmdb命令
echo "instance_name,type,instanceId,publicip,Privateip,zone,keyname,Osname,time,syssize,datasize"
tccli cvm DescribeInstances | jq '.InstanceSet[]|{a:.InstanceName, b:.InstanceType, o:.InstanceId ,c:.PublicIpAddresses[], d:.PrivateIpAddresses[], e:.Placement.Zone, f:.Tags[].Key, g:.OsName, h:.CreatedTime, l:.SystemDisk.DiskSize, j:.DataDisks[].DiskSize}' | jq  -s  "sort_by(.CreatedTime) | .[] " | jq -r '[.[]] | @csv'

#腾讯云db信息
cbd)
tccli  cdb DescribeDBInstances | jq '.Items[] | [.InstanceName ,.InstanceId ,.EngineVersion ,.Zone ,.Vip ,.Volume ,.Cpu ,.Memory]' 


#华为云服务器信息 
python /opt/APIGW-python-sdk-2.0.4/main.py >> xx.json
cat  xx.json  | jq '.servers[] | [.name ,.addresses."df79ecf2-cda1-4c52-a68d-8077a511509e"[0,1].addr ,.flavor.name ,.metadata.image_name .created]' | jq -r '[.[]] | @csv' 

