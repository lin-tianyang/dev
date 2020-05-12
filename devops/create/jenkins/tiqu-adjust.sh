#下载adjust数据
adjustyear=`date +%Y`
adjustmount=$3
startday=$1
stopday=$2

rm -f /data/test/wst/wst-adjust/*csv.gz

for i in `seq $startday $stopday`
do
ii=`printf "%02d\n" $i`
aws s3 sync  s3://gt-adjust-data/wst/"$adjustyear"-"$adjustmount"/ /data/test/wst/wst-adjust/ --exclude "*" --include en9p3m0nau4g_"$adjustyear"-"$adjustmount"-"$ii"* 
done
 
echo "{app_version},{activity_kind},{click-time},{installd_at},{create_at},{idfa||gps_adid},{user_agent},{ip_address},{city},{device_name},{device_type},{os_version},{event_name}" >> /data/test/wst-adjust/wst-adjust-"$adjustyear""$adjustmount""$startday"_"$stopday".csv
cd /data/test/wst/wst-adjust/ 
zcat * | awk -F ',' '{print $4","$22","strftime("%F-%H:%M:%S",$23)","strftime("%F-%H:%M:%S",$30)","strftime("%F-%H:%M:%S",$35)","$60","$76","$79","$84","$87","$88","$92","$101}' |grep -vw os_version >>/data/test/wst-adjust/wst-adjust-"$adjustyear""$adjustmount""$startday"_"$stopday".csv
#sz /data/test/wst-adjust-"$adjustyear""$adjustmount""$adjustday".csv
