#!/bin/bash
##############################################################################
# Description: 结合jenkins，自动更新wst代码                                  #                        
# date: 2019-02-06                                                           #                                                              
# Author: lintianyang                                                        #                                                                 
# Emain: jarvislin@goatgames.com                                             # 
# Up-Explain: 调整开关服顺序,可以多ip,多服批量更新，加快更新速度  version-2.0#                                        
# Explanation：$1==选项 $2==文件 $3==开服数 $4=玩法组数                      #                                                                         
# For example：/bin/bash /usr/local/shell/new_wst_gamecode.sh $1 $2 $3 $4    #                                           
##############################################################################
codepwd=/data/wst/server-pkg
codetmp=/data/gt-logbus/wst/wst-code
yunweicode=/home/yunwei/wstcode
gttime=`date +"%Y年%m月%d日%H时"`
#wstip=/usr/local/shell/check/wstservice.txt             
#内网查看代码质量 
#sonar-scanner   -Dsonar.projectKey=wst   -Dsonar.sources=.   -Dsonar.host.url=http://192.168.29.36:9000   -Dsonar.login=bd784ca79bbd47e6c60d4185714883ab46cbf13d
lastpwd=`echo ${@:4} | awk -F '/' '{print $1}'`
lastfile=`echo ${@:4} | awk -F '/' '{print $2}'`
#因为全球服基本固定
global_ip=xxx
global_config="wst-g1config.json"



#调整客户端状态,因为开服时间不固定需要手动开发
replace_clinet(){
/bin/bash /usr/local/shell/wst-clinet.sh stopgame
}



#传输代码包到指定路径,并删除过时的代码（ip去重,避免重复上传) 
function wst-sync(){
#1.上传global代码
scp -P 61618 $codetmp/$lastpwd/$lastfile   yunwei@$global_ip:$codepwd/
#ssh -o StrictHostKeyChecking=no -p61618    yunwei@$global_ip "cp -a $yunweicode/$lastfile $codepwd/"
#2.上传fight代码
for fight_ip in `cat /usr/local/shell/wstlist/fight | awk '{print $1}'|head -n $2  | sort | uniq`
do
        scp -P 61618 $codetmp/$lastpwd/$lastfile   yunwei@$fight_ip:$codepwd/
#ssh -o StrictHostKeyChecking=no -p61618  yunwei@$fight_ip "cp -a $yunweicode/$lastfile $codepwd/"        
done
#3.上传wf和main代码
for main_ip in `cat /usr/local/shell/wstlist/main | awk '{print $1}'|head -n $2 | sort | uniq`
do

        scp -P 61618 $codetmp/$lastpwd/$lastfile   yunwei@$main_ip:$codepwd/
#ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cp -a $yunweicode/$lastfile $codepwd/"        
done
}


function addserver (){
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $1}'`
main_config=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $3}'`
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "cd  $codepwd &&tar -zxf $lastfile '*install.py' '*run.py' --strip-components 1  -C . && python  install.py $fight_process $lastfile $fight_config && python  run.py start $main_process"
done
}


#解压安装压缩包,顺时针安装
function installcode(){
#cd $codetmp/$lastpwd/

#1.安装global进程代码
ssh -o StrictHostKeyChecking=no -p61618  yunwei@$global_ip "cd  $codepwd &&tar -zxf $lastfile '*install.py' '*run.py' --strip-components 1  -C . && python  install.py global $lastfile $global_config"

#2.安装fight进程代码
for fight_process in `cat /usr/local/shell/wstlist/fight | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
fight_ip=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $1}'`
fight_config=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $3}'`
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "cd  $codepwd &&tar -zxf $lastfile '*install.py' '*run.py' --strip-components 1  -C . && python  install.py $fight_process $lastfile $fight_config "       
#授权
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done


#2.安装main+wf进程代码
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $1}'`
main_config=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $3}'`

ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cd  $codepwd &&tar -zxf $lastfile '*install.py' '*run.py' --strip-components 1  -C . && python  install.py $main_process $lastfile $main_config "       
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done

#安装玩法
for wf_process in `cat /usr/local/shell/wstlist/wf | awk '{print $2}'|sed -n "$3"p |sort -nr | uniq`
do

wf_ip=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $1}'`
wf_config=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $3}'`

ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cd  $codepwd &&tar -zxf $lastfile '*install.py' '*run.py' --strip-components 1  -C . && python  install.py $wf_process $lastfile $wf_config "       
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done
}


#解压安装压缩包,顺时针安装
function patchcode(){
#cd $codetmp/$lastpwd/

#1.安装global进程代码
ssh -o StrictHostKeyChecking=no -p61618  yunwei@$global_ip "cd  $codepwd && python  install.py global $lastfile $global_config"

#2.安装fight进程代码
for fight_process in `cat /usr/local/shell/wstlist/fight | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
fight_ip=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $1}'`
fight_config=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $3}'`
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "cd  $codepwd  && python  install.py $fight_process $lastfile $fight_config "       
#授权
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done


#2.安装main+wf进程代码
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $1}'`
main_config=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $3}'`

ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cd  $codepwd && python  install.py $main_process $lastfile $main_config "       
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done

#安装玩法
for wf_process in `cat /usr/local/shell/wstlist/wf | awk '{print $2}'|sed -n "$3"p |sort -nr | uniq`
do

wf_ip=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $1}'`
wf_config=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $3}'`

ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cd  $codepwd  && python  install.py $wf_process $lastfile $wf_config "       
ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "sudo chmod -R 755 /data/wst/server-pkg &&  sudo chown -R yunwei:yunwei /data/wst/server-pkg && sudo chown yunwei:yunwei -R /data/service/"
done
}


#按规范关闭服务器进程,逆时针关闭进程
function  stoppro(){      
#1.先关main等进程
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2  |sort -nr | uniq`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $1}'` 
#ssh -o StrictHostKeyChecking=no -p61618  yunwei@$main_ip `cat /usr/local/shell/wstlist/main | grep -w $main_ip | awk '{print $2}'`
        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$main_ip "cd $codepwd && python  run.py stop $main_process"        
done


#2.在关fight进程
for fight_process in `cat /usr/local/shell/wstlist/fight | awk '{print $2}'| head -n $2  |sort -nr | uniq`
do
fight_ip=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $1}'`

        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$fight_ip "cd $codepwd && python  run.py stop $fight_process"        
done

#3.在关组玩法进程
for wf_process in `cat /usr/local/shell/wstlist/wf | awk '{print $2}'| head -n $3 |sort -nr | uniq`
do
wf_ip=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $1}'`

        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$wf_ip "cd $codepwd && python  run.py stop $wf_process"        
done

#4.最后关global进程
ssh -o StrictHostKeyChecking=no -p61618  yunwei@$global_ip "cd $codepwd && python  run.py stop global"
}






#按规范开启服务器进程，顺时针启动 
function  startpro(){
#1.先起global进程
ssh -o StrictHostKeyChecking=no -p61618  yunwei@$global_ip "cd $codepwd && python  run.py  start global"


#3.在起组玩法进程
for wf_process in `cat /usr/local/shell/wstlist/wf | awk '{print $2}'|head -n $3 |sort -n`
do
wf_ip=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $1}'`

        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$wf_ip "cd $codepwd && python  run.py start $wf_process"        
done


#2.在起fight进程
for fight_process in `cat /usr/local/shell/wstlist/fight | awk '{print $2}'|head -n $2`
do
fight_ip=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $1}'`

        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$fight_ip "cd $codepwd && python  run.py start $fight_process"        
done


#4.在起main等进程
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $main_process | awk '{print $1}'`
        ssh -o StrictHostKeyChecking=no -p61618  yunwei@$main_ip "cd $codepwd && python  run.py start $main_process"        
done
}




#回滚代码
function roll_back(){
#cd $codetmp/$lastpwd/

#1.回滚global机器代码
ssh -o StrictHostKeyChecking=no -p61618  yunwei@$global_ip "cd  $codepwd &&python install.py global revert $lastfile"

#2.回滚fight进程代码
for fight_process in `cat /usr/local/shell/wstlist/fight | awk '{print $2}'|head -n $2  | sort -n  | uniq`
do
fight_ip=`cat /usr/local/shell/wstlist/fight | grep -w $fight_process | awk '{print $1}'`
        ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "cd  $codepwd &&python install.py $fight_process revert $lastfile"       
done


#2.回滚main进程代码
for main_process in `cat /usr/local/shell/wstlist/main | awk '{print $2}'|head -n $2  | sort -n | uniq`
do
main_ip=`cat /usr/local/shell/wstlist/main | grep -w $fight_process | awk '{print $1}'`
        ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "cd  $codepwd &&python install.py $main_process revert $lastfile"       
done
#回滚wf进程代码
for wf_process in `cat /usr/local/shell/wstlist/wf | awk '{print $2}'|head -n $3 | sort -n | uniq`
do
wf_ip=`cat /usr/local/shell/wstlist/wf | grep -w $wf_process | awk '{print $1}'`
        ssh -o StrictHostKeyChecking=no -p61618    yunwei@$wf_ip "cd  $codepwd &&python install.py $wf_process revert $lastfile"       
done
}


#检查日志是否有报错
function checkprocess(){

ssh -o StrictHostKeyChecking=no -p61618    yunwei@$global_ip "/bin/bash /usr/local/shell/checkwstlog.sh &&  ps -ef | grep -v grep | grep  skynet"  

for main_ip in `cat /usr/local/shell/wstlist/main | awk '{print $1}'|head -n $2  | sort -n | uniq`
do
        ssh -o StrictHostKeyChecking=no -p61618    yunwei@$main_ip "/bin/bash /usr/local/shell/checkwstlog.sh &&  ps -ef | grep -v grep | grep  skynet "       
done

for fight_ip in `cat /usr/local/shell/wstlist/fight | awk '{print $1}'|head -n $2  | sort -n | uniq`
do
        ssh -o StrictHostKeyChecking=no -p61618    yunwei@$fight_ip "/bin/bash /usr/local/shell/checkwstlog.sh &&  ps -ef | grep -v grep | grep  skynet"       
done
}



case $1 in 
        only_upload)
                wst-sync        $1 $2     
        ;;
        full_update)
                replace_clinet
                wst-sync        $1 $2  
                stoppro         $1 $2 $3
                installcode     $1 $2
                startpro        $1 $2 $3
                checkprocess    $1 $2
        ;;
        patch_update)
                wst-sync        $1 $2 $3 
                patchcode     $1 $2
                checkprocess    $1 $2
        ;;
        roll_back)
                stoppro         $1 $2 $3 
                roll_back       $1 $2 $3
        ;;
        stop_game)
                replace_clinet
                stoppro         $1 $2 $3
        ;;
        start_game)
                installcode     $1 $2
                startpro        $1 $2 $3
        ;;        
esac
