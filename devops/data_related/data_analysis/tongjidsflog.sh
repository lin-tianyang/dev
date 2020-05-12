#！/bin/bash
>/usr/local/shell/check/dsflog.csv
>/usr/local/shell/check/eu_dsflog.csv
>/usr/local/shell/check/na_dsflog.csv


cd /data/test/dsf/EU/
year=2020
month=03

for i in `seq 1 25`
do

        for x in `cat /usr/local/shell/check/dsftablename`
        do
ii=`printf "%02d\n" $i`
ll=`cat dsf-10008-$year-$month-$ii* | grep $x | awk '{sum+=$2} END {print sum}'` 
echo $x","$year-$month-$i","$ll >> /usr/local/shell/check/eu_dsflog.csv

        done

done

cd  /data/test/dsf/NA/

for i in `seq 1 25`
do


        for x in `cat /usr/local/shell/check/dsftablename`
        do
ii=`printf "%02d\n" $i`
ll=`cat dsf-10008-$year-$month-$ii* | grep $x | awk '{sum+=$2} END {print sum}'`
echo $x","$year-$month-$i","$ll >> /usr/local/shell/check/na_dsflog.csv

        done

done
