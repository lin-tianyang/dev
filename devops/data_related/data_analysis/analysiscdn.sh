#!/bin/bash
#############################################################################
# Description:分析多项目cdn使用情况                                         # 
# date: 2020-05-07                                                          #                                                          
# Emain: jarvislin@goatgames.com                                            #                                               
# Explanation： 更新了文件查看情况,文件较多时可能占用比较长的时间           #
# For example：/bin/bash analysiscdn.sh 06 ksr                              #                        
#############################################################################



project=$2
cdnyear=`date +%Y`
cdnmount=`date +%m`
cdnday=$1
anapwd=/data/test/$project/$project-cdn
pwfile=/data/test/$project/$project-cdn/file
mkdir -p $pwfile
rm -f $pwfile/*.gz
#wst
aws s3 sync  s3://gt-cdn-log/$project-client/   $pwfile/    --exclude "*" --include xxx.$cdnyear-$cdnmount-$cdnday*
#ksr
#aws s3 sync  s3://gt-cdn-log/$2/ $pwfile/    --exclude "*" --include "xxx.$cdnyear-$cdnmount-$cdnday*"
cd $pwfile

#
sourcedate=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' | awk '{print $4,$5}'`
#查看节点情况
node=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' | awk '{print $3}' |  sort | uniq -c |awk '{ print $2","$1}' | sort -t , -k2nr`
#查看ip数量
ip=`echo "$sourcedate" | awk '{print $2}' | sort | uniq |wc -l`

#查看获取源的比例
miss=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' | grep -iw Miss | awk '{print $5}' | sort | uniq |wc -l`


#根据ip统计文件大小
#filesize=`echo "$sourcedate" | awk  '{sum[$2]+=$1}END{for(c in sum){print c,sum[c]}}' |  sort -k2nr | awk '{print $1","($2/1024/1024)}' |  sort -t , -k2nr`     
#完全排除去重下载文件数量
num_uniq=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' |awk '{print $5,$8}' |  awk '!a[$1" "$2]++{print}' | awk '{print $1}' | sort | uniq -c |  awk '{ print $2","$1}' |sort -t , -k1nr`
#不去重下载文件数量
num=`echo "$sourcedate" | awk '{print $2}' | sort | uniq -c |   awk '{ print $2","$1}' |sort -t , -k1nr` 
#统计ip下载时间和文件大小
#time-taken=`zcat * | grep -Evw 'xxx|x-edge-location|#Version' |awk '{print $19,$5}' |awk  '{sum[$2]+=$1}END{for(c in sum){print c,sum[c]}}' |sort -t , -k2nr`
#花费时间和文件大小
time_taken=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' | awk '{print $4","$5","$8","$19}' | sort -t , -k2nr | awk -F ',' '{s[$2] += $1; a[$2] += $4; }END{ for(i in s){  print i","s[i]","a[i] } }' |  sort -t , -k1nr`


#错误源文件
error=`zcat *.gz | grep -Evw 'xxx|x-edge-location|#Version' | grep -i error`
#错误次数
errnum=`echo "$error" | awk '{print $4,$5}' | awk '{print $2}' | sort | uniq  | wc -l`
#多次错误下载
eperr=`echo "$error"  | awk '{print $4,$5}' | awk '{print $2}' | sort | uniq -c | sort -nr | awk '$1 >2"print $0"' | wc -l`

#详细错误信息
echo "time,node,sc-bytes,ip,file,sc-status,result-type,time-taken,front-response,error-detailed" > /data/test/$project/$project-cdn/$project_error-$cdnyear-$cdnmount-$cdnday.csv
zcat *.gz | grep -Evw 'xxx|x-edge-location' | sort -k5nr | grep -i error -C 3 | awk '{print $2","$3","$4/1024/1024","$5","$8","$9","$14","$19","$23","$29}'   >> /data/test/$project/$project-cdn/wsterror-$cdnyear-$cdnmount-$cdnday.csv


#判断ipv6
#awk -F '.' '{ if ( ( $1 > 256 || $1 < 0 ) || ( $2 > 256 || $2 < 0 ) || ( $3 > 256  || $3 < 0 ) || ( $4 > 256 || $4 < 0     )) print $0 ,"is incorrect"}'
#echo “$node,$ip,$miss,$filesize,$num-uniq,$num,$error”| awk -F ','  '{print $1","$2","$3","$4","$5","$6","$7}'  >>/data/test/$project/$project-cdn/$project-$cdnyear-$cdnmount-$cdnday.csv
#根据ip,合并文件
#awk 'FNR==NR{a[$1]=$2}FNR<NR{a[$1]?a[$1]=a[$1]" "$2:a[$1]=a[$1]" 0 "$2}END{for(i in a)print i,a[i]}' 123.csv 234.csv  

#echo  "$filesize"       >/data/test/$project/$project-cdn/filesize.csv
echo  "$num_uniq"       >/data/test/$project/$project-cdn/num_uniq.csv
echo  "$num"            >/data/test/$project/$project-cdn/num.csv
echo  "$node"           >/data/test/$project/$project-cdn/node.csv
echo  "$ip"             >/data/test/$project/$project-cdn/ip.csv
echo  "$miss"           >/data/test/$project/$project-cdn/miss.csv
echo  "$errnum"         >/data/test/$project/$project-cdn/errnum.csv
echo  "$eperr"          >/data/test/$project/$project-cdn/eperr.csv
echo  "$time_taken"     >/data/test/$project/$project-cdn/time_taken.csv
 

cd /data/test/$project/$project-cdn/
#求交集
join -t, num.csv num_uniq.csv >total_num.csv
join -t, total_num.csv time_taken.csv >total.csv

#合并分析文件
#echo "ip,filesize,ip,file_num_uniq,ip,file_num,node,nd_num,totalip,sourceip,errnum,eperr,time" >/data/test/$project/$project-cdn/$project-$cdnyear-$cdnmount-$cdnday.csv
#paste  -d, filesize.csv num_uniq.csv  num.csv node.csv ip.csv miss.csv errnum.csv eperr.csv time-taken.csv>>/data/test/$project/$project-cdn/$project-$cdnyear-$cdnmount-$cdnday.csv
echo "ip,file_num,file_uniq_num,size,time,node,node_total,ip_total,miss_total,err_total,eperr" >/data/test/$project/$project-cdn/$project-$cdnyear-$cdnmount-$cdnday.csv
paste -d, total.csv node.csv ip.csv miss.csv errnum.csv  eperr.csv >>/data/test/$project/$project-cdn/$project-$cdnyear-$cdnmount-$cdnday.csv

exit
