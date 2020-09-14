#!/bin/bash
dir="/usr/local/ziyuantongji"
GROUP_ID="$dir/jifangid.txt"
#STIME=$(($(date +%s) -2592000))
#ETIME=$(date +%s)
STIME=$(date -d"2019-3-21 00:00:00" +%s)
ETIME=$(date -d"2018-1-22 15:59:59" +%s)
CPU_NUM="wc -l $dir/cpu_itemid.txt"

#function cpu load itemid
function cpu_itemid(){
  >$dir/cpu_itemid.txt
  >$dir/tmp.txt
  for id in `cat $GROUP_ID`
  do
    mysql -uxxx -pxxx -Dzabbix -e "select hs.ip,hg.hostid,i.itemid from interface as hs right join hosts_groups as hg on hs.hostid=hg.hostid right join items as i on hg.hostid=i.hostid where hg.groupid='$id' and key_='system.cpu.load[all,avg5]';">>tmp.txt
    sed -i '/itemid/d' $dir/tmp.txt
  done
  sort $dir/tmp.txt >$dir/cpu_itemid.txt
}

#function cpu use
function cpu_use(){
  >$dir/cpu_use.txt
  CPU_NUM=`cat $dir/cpu_itemid.txt|wc -l`
  for NUM in `seq $CPU_NUM`
  do
     CPU_IP=$(awk 'NR=="'"$NUM"'"{print $1}' $dir/cpu_itemid.txt)
     CPU_ID=$(awk 'NR=="'"$NUM"'"{print $3}' $dir/cpu_itemid.txt)
     LOAD=$(mysql -uxxx -pxxx -Dzabbix -e "SELECT avg(value),max(value) FROM history  WHERE itemid='$CPU_ID' and clock>= '$STIME' AND clock< '$ETIME';")
     CPU_LOAD=$(echo "$LOAD" | sed "/max/d")
     echo -e "$CPU_IP\t$CPU_LOAD">>$dir/cpu_use.txt
  done
}

#function cpu util itemid
function cpu_util_itemid(){
   >$dir/cpu_util_itemid.txt
   >$dir/tmp.txt
   for id in `cat $GROUP_ID`
   do
    mysql -uxxx -pxxx -Dzabbix -e "select hs.ip,hg.hostid,i.itemid from interface as hs right join hosts_groups as hg on hs.hostid=hg.hostid right join items as i on hg.hostid=i.hostid where hg.groupid='$id' and key_='system.cpu.util[all,user,avg1]';">>tmp.txt
    sed -i '/itemid/d' $dir/tmp.txt
   done
    sort $dir/tmp.txt >$dir/cpu_util_itemid.txt
}

#function cpu_util
function cpu_util(){
  >$dir/cpu_util.txt
  CPU_UTIL=`cat $dir/cpu_util_itemid.txt|wc -l`
  for NUM in `seq $CPU_UTIL`
  do
    CPU_IP=$(awk 'NR=="'"$NUM"'"{print $1}' $dir/cpu_util_itemid.txt)
    CPU_ID=$(awk 'NR=="'"$NUM"'"{print $3}' $dir/cpu_util_itemid.txt)
    LOAD=$(mysql -uxxx -pxxx -Dzabbix -e "SELECT avg(value) FROM history  WHERE itemid='$CPU_ID' and clock>= '$STIME' AND clock< '$ETIME';")
    CPU_LOAD=$(echo "$LOAD" | sed "/avg/d")
    echo -e "$CPU_IP\t$CPU_LOAD">>$dir/cpu_util.txt
  done
}


#function memory itemid
function memory_itemid(){
  >$dir/memory_itemid.txt
  >$dir/tmp.txt
  for id in `cat $GROUP_ID`
  do
    mysql -uxxx -pxxx -Dzabbix -e "select hs.ip,hg.hostid,i.itemid from interface as hs right join hosts_groups as hg on hs.hostid=hg.hostid right join items as i on hg.hostid=i.hostid where hg.groupid='$id' and key_='vm.memory.free[percent]';">>tmp.txt
    sed -i '/itemid/d' $dir/tmp.txt
  done
    sort $dir/tmp.txt >$dir/memory_itemid.txt
}

#function memory use
function memory_use(){
  >$dir/memory_use.txt
  MEM_USE=`cat $dir/memory_itemid.txt|wc -l`
  for NUM in `seq $MEM_USE`
  do
    MEM_IP=$(awk 'NR=="'"$NUM"'"{print $1}' $dir/memory_itemid.txt)
    MEM_ID=$(awk 'NR=="'"$NUM"'"{print $3}' $dir/memory_itemid.txt)
    LOAD=$(mysql -uxxx -pxxx -Dzabbix -e "SELECT avg(value) FROM history  WHERE itemid='$MEM_ID' and clock>= '$STIME' AND clock< '$ETIME';")
    MEM_LOAD=$(echo "$LOAD" | sed "/avg/d")
    echo -e "$MEM_IP\t$MEM_LOAD">>$dir/memory_use.txt
  done

}

#function disk itemid
function disk_itemid(){
  >$dir/disk_itemid.txt
  >$dir/tmp.txt
  for id in `cat $GROUP_ID`
  do
    mysql -uxxx -pxxx -Dzabbix -e "select hs.ip,hg.hostid,i.itemid from interface as hs right join hosts_groups as hg on hs.hostid=hg.hostid right join items as i on hg.hostid=i.hostid where hg.groupid='$id' and key_='vfs.fs.size[/data,pfree]';">>tmp.txt
    sed -i '/itemid/d' $dir/tmp.txt
  done
    sort $dir/tmp.txt >$dir/disk_itemid.txt
}

#function disk use
function disk_use(){
  >$dir/disk_use.txt
  DISK_USE=`cat $dir/disk_itemid.txt|wc -l`
 for NUM in `seq $DISK_USE`
 do
   DISK_IP=$(awk 'NR=="'"$NUM"'"{print $1}' $dir/disk_itemid.txt)
   DISK_ID=$(awk 'NR=="'"$NUM"'"{print $3}' $dir/disk_itemid.txt)
   LOAD=$(mysql -uxxx -pxxx -Dzabbix -e "SELECT avg(value) FROM history  WHERE itemid='$DISK_ID' and clock>= '$STIME' AND clock< '$ETIME';")
   DISK_LOAD=$(echo "$LOAD" | sed "/avg/d")
   echo -e "$DISK_IP\t$DISK_LOAD">>$dir/disk_use.txt
 done 
}

function main(){
  cpu_itemid
  cpu_use
  memory_itemid
  memory_use
  cpu_util_itemid
  cpu_util
  disk_itemid
  disk_use
  join -a1 cpu_use.txt memory_use.txt|join - cpu_util.txt|join - disk_use.txt >$dir/sum_all.txt
#  cat disk_use.txt >$dir/sum_all.txt
  sed -i '1i IP 服务器负载（%） 负载峰值（%） 内存空闲百分比（%） CPU使用率（%） /data分区磁盘空闲率（%）' $dir/sum_all.txt
}

main $*


