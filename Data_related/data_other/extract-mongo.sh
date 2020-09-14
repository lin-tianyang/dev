#/bin/bash
#提取mongo数据
if [[ $1 == "global" ]]
then
wstport=xxx
elif [[ $1 == "server" ]]
then
wstport=xxx
fi

wsttable="$2"
wstsdkday=`date "+%Y-%m-%d"`
sql=`echo ${@:4}`

mkdir -p /usr/local/shell/data/
echo "$sql" | mongo --host xxx --port $wstport --quiet $wsttable >>/usr/local/shell/data/$3_$wstsdkday.csv
