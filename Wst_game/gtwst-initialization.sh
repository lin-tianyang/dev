#!/bin/bash
#############################################################################
# Description:初始化系统（centos7.6）                                        # 
# date: 2019-12-4                                                           #                                                          
# Emain: jarvislin@goatgames.com                                            #                                               
# Explanation：因为会centos用户，不要用centos用户运行                          #
# For example：/bin/bash scp.sh   $1  $2 $3                                 #                        
#############################################################################
#usage() {
#    echo "请按如下格式执行"
#    echo "USAGE: bash $0 函数名1#函数名2"
#    echo "USAGE: bash $0 epel#ulimits#ssh"
#    exit 1
#}
#


#安装pip，python3，pymongo
function gt-python (){
yum install -y python3 
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install  pymongo
}

#增加epel源
function gt-epel(){
        yum install epel-release -y >/dev/null 2>&1
        sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/epel.repo
        sed -i 's/#baseurl/baseurl/g' /etc/yum.repos.d/epel.repo
        sed -i '6s/enabled=0/enabled=1/g' /etc/yum.repos.d/epel.repo
        sed -i '7s/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/epel.repo
        yum clean all >/dev/null 2>&1
        #yum -y install cloud-utils-growpart
        #growpart /dev/xvda 1
        #resize2fs /dev/xvda 1
        #阿里云机器用aliyun epel
        #echo "[EPEL 配置] ==> OK"
}


#增加文件打开数
function gt-ulimits(){
cat > /etc/security/limits.conf <<EOF
* soft noproc 65536
* hard noproc 65536
* soft nofile 65536
* hard nofile 65536
EOF
# centos 7.3 还是 7.4开始， 这个文件有一部分soft 和 nproc 内容，登陆后会被覆盖，/etc/security/limits.conf 不会生效
echo > /etc/security/limits.d/20-nproc.conf 
ulimit -n 65536
ulimit -u 65536
#echo "[ulimits 配置] ==> OK"
}


#修改内核参数，增加缓存区，减少等待时间
#可以接收更大的包，增加对轻量ddos抗性
#增加corefile文件，知道程序宕机原因
function gt-kernel(){
mkdir -p /data/corefiles/
cat > /etc/sysctl.conf <<EOF
fs.file-max = 65536
net.core.netdev_max_backlog = 32768
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.wmem_max = 16777216
net.ipv4.conf.all.arp_ignore = 0
net.ipv4.conf.lo.arp_announce = 0
net.ipv4.conf.lo.arp_ignore = 0
net.ipv4.ip_local_port_range = 5000 65000
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
kernel.core_pattern = /data/corefiles/core.%e.%p.%t 
EOF
sysctl -p >/dev/null 2>&1
#echo "[内核 优化] ==> OK"
}

# 增加操作系统记录数量，显示时间，ip，用户
function gt-history(){
        if ! grep "HISTTIMEFORMAT" /etc/profile >/dev/null 2>&1
        then echo '
        UserIP=$(who -u am i | cut -d"("  -f 2 | sed -e "s/[()]//g")
        export HISTTIMEFORMAT="[%F %T] [`whoami`] [${UserIP}] " 
        ulimit -c unlimited' >> /etc/profile;
        
        fi
        sed -i "s/HISTSIZE=1000/HISTSIZE=5000/" /etc/profile
#echo "[history 优化] ==> OK"
}

function  gt-mailx(){
yum install mailx -y
yum install -y sendmail 
yum install -y sendmail-cf
sed -i 's#127.0.0.1#0.0.0.0#g'    /etc/mail/sendmail.mc
sed -i 's#dnl TRUST_AUTH_MECH#TRUST_AUTH_MECH#g' /etc/mail/sendmail.mc
#sed -i 's#dnl define(`confAUTH_MECHANISMS'#define(`confAUTH_MECHANISMS'#g' /etc/mail/sendmail.mc
m4 /etc/mail/sendmail.mc  > /etc/mail/sendmail.cf     
cat > /etc/sysctl.conf <<EOF
set from=18820304608@139.com
set smtp=smtp://smtp.139.com
set smtp-auth-user=18820304608@139.com
set smtp-auth-password=zx7847165
set smtp-auth=login
EOF
systemctl restart sendmail
systemctl status sendmail
systemctl enable sendmail
}


function  gt-mutt(){
yum -y install  mutt msmtp  ca-certificates

cat >/root/.msmtprc <<EOF
defaults
auth on
tls on
tls_starttls off
tls_trust_file /etc/ssl/certs/ca-bundle.crt
account freemail
host smtp.gmail.com
port 465
user jarvislin@goatgames.com
password as7847165
from jarvislin@goatgames.com
logfile /var/log/msmtp.log
account default:freemail
EOF
chmod 600 ~/.msmtprc
touch /var/log/msmtp.log

 
cat  >/etc/Muttrc  <<EOF
set from="jarvislin@goatgames.com"
set sendmail="/bin/msmtp"
set use_from=yes
set realname="lty"
set editor="vi"
set charset="utf-8"
EOF


}
# 关闭selinux，关闭iptables,默认以关闭
function gt-security(){
        > /etc/issue
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0 >/dev/null 2>&1
        #systemctl stop firewalld.service
        #systemctl disable firewalld.service
        yum install -y openssl openssh bash >/dev/null 2>&1
        #echo "[安全配置] ==> OK"
}

#安装常用软件
function gt-other(){
        yum groupinstall Development tools -y >/dev/null 2>&1
        yum install -y vim wget lrzsz telnet traceroute iotop tree mtr nmap-ncat rlwrap>/dev/null 2>&1
        yum install -y ncftp axel git zlib-devel openssl-devel unzip xz libxslt-devel libxml2-devel libcurl-devel >/dev/null 2>&1
        #echo "[安装常用工具] ==> OK"
        source /etc/profile
}

function install-mongodb(){
touch  /etc/yum.repos.d/mongodb-org-3.4.repo
cat /etc/yum.repos.d/mongodb-org-3.4.repo << EOF 
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc

EOF


yum install -y mongodb-org


#wst-glodb-test.conf   wst-serdb-test.conf
mkdir -p  /etc/mongod/
touch   /etc/mongod/wst-mongod-test.conf
cat /etc/mongod/wst-mongod-test.conf << EOF 
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/gtgbmm.log

storage:
  dbPath: /data/gtgbmm/
  journal:
    enabled: true

processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/gtgbmm.pid  # location of pidfile

net:
  port: 37018
  bindIp: 172.28.1.67  # Listen to local interface only, comment to listen on all interfaces.
  maxIncomingConnections: 1000

replication:
  oplogSizeMB: 500    #replication操作日志的最大尺寸，如果太小，secondary将不能通过oplog来同步数据，只能全量同步
  replSetName: gbwst    #副本集名称，副本集中所有的mongod实例都必须有相同的名字，Sharding分布式下，不同的sharding应该使用不同的repSetName
EOF


touch /usr/lib/systemd/system/wst-mongod-test
cat  /usr/lib/systemd/system/wst-mongod-test   <<EOF
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network.target

[Service]
User=mongod
Group=mongod
ExecStart=/usr/bin/mongod -f /etc/mongod/gtgbmm.conf
ExecStartPre=/usr/bin/mkdir -p /var/run/mongodb
ExecStartPre=/usr/bin/chown mongod:mongod /var/run/mongodb
ExecStartPre=/usr/bin/chmod 0755 /var/run/mongodb
PermissionsStartOnly=true
PIDFile=/var/run/mongodb/gtgbmm.pid

Type=forking
LimitFSIZE=infinity
LimitCPU=infinity
LimitAS=infinity
LimitNOFILE=64000
LimitNPROC=64000
LimitMEMLOCK=infinity
TasksMax=infinity
TasksAccounting=false

[Install]
WantedBy=multi-user.target
EOF
chown mongod:mongod -R /etc/mongod/
#注意加开机自启动
}


function install-mysql(){
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum localinstall mysql57-community-release-el7-11.noarch.rpm
yum install -y mysql-community-server
systemctl enable mysqld
systemctl daemon-reload
systemctl restart mysqld
TEMP_DB_PASSWORD=`grep "temporary password"  /var/log/mysqld.log | awk -F: '{print $NF}' | tr -d '[:space:]'`
mysql -uroot -p$TEMP_DB_PASSWORD --connect-expired-password  << EOF
alter user "root"@"localhost"  identified by "ZBO564knb#";
flush privileges;
EOF
}


function install-go(){
https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz 
#tar -C /usr/local -zxvf  go1.11.5.linux-amd64.tar.gz
echo "export GOROOT=/usr/local/go"   >> /etc/profile
echo "export PATH=$PATH:$GOROOT/bin" >> /etc/profile
}


#删除centos用户,添加yunwei和wst-dev用户，并让yunwei拥有root权限
function gt-yonghu(){
>/root/.ssh/known_host
rm -rf /home/centos
userdel centos
useradd wst-dev 
useradd yunwei
mkdir -p /data/wst/server-pkg
mkdir -p /data/service/log
mkdir -p /home/wst-dev/.ssh  /home/yunwei/.ssh
cp -ar /etc/skel/.bashrc /home/yunwei/
cp -ar /etc/skel/.bashrc /home/wst-dev/
cp -ar /etc/skel/.bash_profile /home/yunwei/.bash_profile
cp -ar /etc/skel/.bash_profile /home/wst-dev/.bash_profile
usermod -d /home/yunwei -s /bin/bash yunwei
usermod -d /home/wst-dev -s /bin/bash wst-dev 
#给用户多加1个秘钥，当跳板机死机的时候可以从另外一台服务器登录,必须要有备份机器
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4RYjaMiD6Y6COPORwgdAgVFtmuA7CDSkO4VGC/gqDL5v2cXj8Ut1RuVh1hxgmjNN4n/IjuzvQYaQWLdCXqhb33UkSlk8DkA0bcgZgY+8CoTVBv+oWbvtYRVNVj2xM29gg8MBs67Sn5jTt8YLYen3z5s5/z0OlqqL3Fd6u3zULD0EVEQZfgvJkCblgULV8vp3E1WhaHKwe/bjk5+95h+vDnpFdbaruIuoraq9RkUf8gzCdxHou1Sj1oIociP9rulb7a+DCev8oeRFQherJUeFp72OxBRgL15XN4DlKB32Ti4Hv570mUnxArrSCKZ3wJStZBSolhV0jFP1UU63fFCOXQ==" >/home/yunwei/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6bf1JTRY+AyWpfcsNDEphX1ol+UehnQoC0haSEXkxiyWfvIGGvuEfcnlNMbtxiNvx2YZSs+pmJu7yyP4aqwpva2kgaosvUXP5pRtGcQG/yPprxtJVZtHhJfMWuFW/qdtS/NRnfPEGD+H56ZndoelX2CQ/rmhSVqrsUNTfZGTayMOqOurxLvIu6E85qmnm+VkSXSlokvqOuRzSJ4zOKcq9rOAovHlVbm4eIskuwwK2HgnvdqPozTsU4tyD0z2gCynJ67++DAORV4YSiFRuS+XeTzeACvVOSwlOYb+oNtpJCJ5rxLKf8JejDgB4UhDlE6oS6+zJi1tN1JUJVMVEAvKD root@gt-shangwu-server" >>/home/yunwei/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCHN3m33kyj3NBEr7bsb/YXKGHS5OZxq7QXoxtNYSeH6cJ3zrA2t/pN4Gbw4LnR47pdY5CwobIzqYLoyKJ4XUuLbTe+eDkwQNxZ7XyBHK7xDjl4hrfut9tYTc0WsiH+x8DodihDggz8NNDmvzt6OvqdiLSYZdJ/aVJk8EhxI20WQt82Io52y9cTkYJOoc9lGwjNbV9EWVYhqGFVqptQyO/0f2dH1mNXyExv8g30R3UsmL/weelo8a9kYySfpcrezkwbEgLkVLdzpontbT15Y4ibCYfWHjbU5LFEgTi+WbBLCHbEwRNewrKB6vLpuR+hxIpk5Svm7ufPfBspdOn3zJQJ aws-wst" >/home/wst-dev/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6bf1JTRY+AyWpfcsNDEphX1ol+UehnQoC0haSEXkxiyWfvIGGvuEfcnlNMbtxiNvx2YZSs+pmJu7yyP4aqwpva2kgaosvUXP5pRtGcQG/yPprxtJVZtHhJfMWuFW/qdtS/NRnfPEGD+H56ZndoelX2CQ/rmhSVqrsUNTfZGTayMOqOurxLvIu6E85qmnm+VkSXSlokvqOuRzSJ4zOKcq9rOAovHlVbm4eIskuwwK2HgnvdqPozTsU4tyD0z2gCynJ67++DAORV4YSiFRuS+XeTzeACvVOSwlOYb+oNtpJCJ5rxLKf8JejDgB4UhDlE6oS6+zJi1tN1JUJVMVEAvKD root@gt-shangwu-server" >>/home/wst-dev/.ssh/authorized_keys
chmod 400  /home/wst-dev/.ssh/authorized_keys 
chmod 400  /home/yunwei/.ssh/authorized_keys 
chown -R wst-dev:wst-dev /home/wst-dev
chown -R yunwei:yunwei   /home/yunwei
su - yunwei -c "source /home/yunwei/.bashrc"
su - wst-dev -c "source /home/wst-dev/.bashrc"
gtyunwei=`cat /etc/sudoers |grep yunwei`
if [ $checkdf -eq 1 ]
then
  echo "yunwei已有root账号"
else
  echo "yunwei     ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers
fi
}




#删除数据磁盘分区
function gt-Uninstalldisk(){
#不同的镜像有不同的uuid一定要注意
>/etc/sysctl.conf
sysctl -p
echo "UUID=f41e390f-835b-4223-a9bb-9b45984ddf8d /                       xfs     defaults        0 0" >/etc/fstab
swapoff /dev/nvme1n1p1
rm -f  /data/swapfile
umount /data 
fdisk /dev/nvme1n1 << EOF  
d
1
w
EOF
fdisk /dev/nvme1n1 << EOF  
d
2
w
EOF
mount -a
}


#添加数据盘和交换分区,数据盘为xfs格式
function gt-disk(){
checkdf=`fdisk -l /dev/nvme1n1 | grep /dev/nvme1n1p1 | wc -l`
if [ $checkdf -eq 1 ]
then
  echo "磁盘以加"
else 
fdisk /dev/nvme1n1 << EOF  
n
p
1

+8G
w
EOF
fdisk /dev/nvme1n1 << EOF  
n
p
2


w
EOF
fi
#mkfs.ext4 /dev/nvme1n1
mkswap /dev/nvme1n1p1
swapon /dev/nvme1n1p1
mkdir -p /data
mkfs.xfs -f /dev/nvme1n1p2
echo "/dev/nvme1n1p2  /data   xfs     defaults        0       0" >> /etc/fstab 
echo "/dev/nvme1n1p1 swap swap defaults 0 0" >> /etc/fstab
mount -a
}

# 修改ssh端口，不允许root用户原程登录,关闭GSSAPI认证
function gt-ssh(){
sed -i "s/#Port 22/Port 61618/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
gss=`cat /etc/ssh/sshd_config | grep -i GSSAPI | wc -l`
if [  $gss -eq 1 ]
then
  echo "gss以添加"
else
  sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/sshd_config
  sed -ir "s/#UseDNS yes/#UseDNS no/" /etc/ssh/sshd_config
  systemctl restart  sshd >/dev/null 2>&1
#echo "[SSH 优化] ==> OK"
fi
}


#查看运行的结果
function gt-check(){
id wst-dev
id yunwei
id centos
/usr/bin/netstat -tnlp
df | grep date 
free -m 
fdisk -l  /dev/nvme1n1p1
} 




##格式必须是: /bib/bash script 函数名1#函数2
## 例如: bash system_init_v1.sh epel#ulimits#ssh
#echo $1 | awk -F "#" '{for(i=1;i<=NF;++i) system($i)}'
gt-epel          
gt-ulimits       
#gt-Uninstalldisk  #主要是重置磁盘分区，可以注释掉
gt-disk
gt-kernel         #这个函数必须放到disk以后，不然挂载不成功
gt-history
gt-security
gt-other
gt-python
gt-yonghu
gt-ssh
install-mysql
gt-check >>11.txt
echo '[Success]System Init OK'
