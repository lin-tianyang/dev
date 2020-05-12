#!/bin/bash
#keys
#keys_unsorted
stodic=/data/test/wst/log
exdic=/data/gt-logbus/wst/wst-logbus/




mkdir -p /data/test/wst/log/csvpwd
cp -ar /data/gt-logbus/wst/wst-logbus/$2/$1*  /data/test/wst/log

cd /data/test/wst/log
for tar in `ls *.tar.gz`  
do 
        tarname=`echo $tar | awk -F '.' '{print $1}'` 
        mkdir -p $tarname-csv
        tar xvf $tar -C $tarname-csv
        cd  $tarname-csv
        for i in `ls *.json`
        do
                name=`echo $i | awk -F '.' '{print $1}'`
                #获取key值
                cat $i | head -n 1 | jq  . | awk -F ':' '{print $1}'  | grep -Ev '{|}' | sed 's/\"//g' | awk -F ',' '{for(i=1;i<=NF;i++) a[i,NR]=$i}END{for(i=1;i<=NF;i++) {for(j=1;j<=NR;j++) printf a[i,j] ",";print ""}}'  >>$name.csv
                #获取name值
                cat $i | jq -r '[.[]] | @csv' >>$name.csv
                
        done
        rm -f *.json
		cd .. 
		tar czf csv-$tarname.tar.gz  $tarname-csv  -C csvpwd
		mv  csv-$tarname.tar.gz csvpwd

done
#高危操作
rm -rf /data/test/wst/log/*-csv
rm -f /data/test/wst/log/*.tar.gz


#远程传输，并上传到共享网盘
ssh -p61618 xxx "/bin/bash /usr/local/shell/wst-json-csv.sh $1 $2"
scp -P 61618 xxx:/data/test/wst/log/csvpwd/$1* /var/www/wst-disk/data/gt/files/wst-gamelog/
mv $wstsdkday.txt /var/www/wst-disk/data/gt/files/gtsdk-data
chown -R www-data:www-data /var/www/wst-disk/ 
chmod 755 -R /var/www/wst-disk/data/gt/files/
sudo -u www-data php /var/www/wst-disk/occ files:scan --path=gt/files/wst-gamelog