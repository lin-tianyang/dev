#目录角标
x=$1
datapath="/data/gamelogs/wam"$x"/data"
echo "datapath:"$datapath
#开始日期
start_date=$2
sleeptime=5000
name=`hostname`
if [ $# -lt 3 ];then
#截止日期是本月最后一天
        amonthlater=`date -d "$start_date next month" +%Y-%m`
        nextmonthfirstday=${amonthlater}"-01"
        end_date=`date -d "$nextmonthfirstday -1day" +%Y-%m-%d`
        end_point=$nextmonthfirstday
else
#截止日期是参数3
        end_date=$3
        end_point=`date -d "$end_date +1day" +%Y-%m-%d`
fi
current_date=$start_date

while [ $current_date != $end_point ]
do

echo "***** current_date:"$current_date" *****"

current_yearmonth=`date -d "$current_date" +%Y-%m`
current_day=`date -d "$current_date" +%d`



echo 1 >sum_$1.txt
while [ "`ls -l $datapath|grep "^-"|grep tar.gz|wc -l`" -gt 0 ]
do
totaltime=`cat sum_$1.txt | awk '{ sum+=$1} END {print sum}'`
	if [ "$sleeptime" -eq "$totaltime"  ]
	then
		python alter.py  "$name,$datapath"   "$current_yearmonth-$current_day"
	fi
       	echo 1 >>sum_$1.txt
       	sleep 1
done

aws s3 sync s3://gt-logbus/wam/$current_yearmonth/$current_day/ $datapath --exclude "*" --include "*.tar.gz"
#touch $datapath/$current_date.tar.gz

current_date=`date -d "$current_date +1day" +%Y-%m-%d`

done
