#!/bin/bash
#目录
#>dsfeu.csv
#>dsfna.csv
#cd /data/gt-logbus/dragon-logbus/NA
#月份
for i in `seq 3 4`
do
 for x in `seq 1 31`
 do
ii=`printf "%02d\n" $i`
xx=`printf "%02d\n" $x` 
nanum=`aws s3  ls s3://gt-logbus/dsf/NA/2020-$ii/$xx/ | grep gz | wc -l`
echo "2020-$ii-$xx,$nanum" >>/usr/local/shell/check/dsfna.csv
 done
done

#cd /data/gt-logbus/dragon-logbus/EU

for i in `seq 3 4`
do
 for x in `seq 1 31`
 do
ii=`printf "%02d\n" $i`
xx=`printf "%02d\n" $x`
eunum=`aws s3  ls s3://gt-logbus/dsf/EU/2020-$ii/$xx/ | grep gz | wc -l`
echo "2020-$ii-$xx,$eunum"  >>/usr/local/shell/check/dsfeu.csv
 done
done
