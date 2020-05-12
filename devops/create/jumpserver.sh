#/bin/bash
systemctl enable firewalld \
  && systemctl start firewalld \
  && firewall-cmd --zone=public --add-port=80/tcp --permanent \
  && firewall-cmd --zone=public --add-port=2222/tcp --permanent \
  && firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="172.17.0.0/16" port protocol="tcp" port="8080" accept" \
  && firewall-cmd --reload \
  && setenforce 0 \
  && sed -i "s/enforcing/disabled/g" /etc/selinux/config

yum update -y \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && yum -y install kde-l10n-Chinese \
  && yum -y reinstall glibc-common \
  && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
  && export LC_ALL=zh_CN.UTF-8 \
  && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
  && yum -y install wget gcc epel-release git \
  && yum install -y yum-utils device-mapper-persistent-data lvm2 \
  && yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo \
  && yum makecache fast \
  && rpm --import https://mirrors.aliyun.com/docker-ce/linux/centos/gpg \
  && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
  && rpm --import https://nginx.org/keys/nginx_signing.key \
  && yum -y install redis mariadb mariadb-devel mariadb-server nginx docker-ce \
  && systemctl enable redis mariadb nginx docker \
  && systemctl start redis mariadb \
  && yum -y install python36 python36-devel \
  && python3.6 -m venv /opt/py3

cd /opt \
  && git clone https://github.com/jumpserver/jumpserver.git \
  && wget https://github.com/jumpserver/luna/releases/download/1.4.8/luna.tar.gz \
  && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
  && source /opt/py3/bin/activate \
  && pip install --upgrade pip setuptools \
  && pip install -r /opt/jumpserver/requirements/requirements.txt \
  && curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io \
  && systemctl restart docker \
  && docker pull jumpserver/jms_coco:1.4.8 \
  && docker pull jumpserver/jms_guacamole:1.4.8 \
  && cd /opt \
  && tar xf luna.tar.gz \
  && chown -R root:root luna \
  && rm -rf /etc/nginx/conf.d/default.conf

cat << EOF > /etc/nginx/conf.d/jumpserver.conf
server {
    listen 80;

    client_max_body_size 100m;  # 录像及文件上传大小限制

    location /luna/ {
        try_files \$uri / /index.html;
        alias /opt/luna/;
    }

    location /media/ {
        add_header Content-Encoding gzip;
        root /opt/jumpserver/data/;
    }

    location /static/ {
        root /opt/jumpserver/data/;
    }

    location /socket.io/ {
        proxy_pass       http://localhost:5000/socket.io/;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        access_log off;
    }

    location /coco/ {
        proxy_pass       http://localhost:5000/coco/;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        access_log off;
    }

    location /guacamole/ {
        proxy_pass       http://localhost:8081/;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        access_log off;
    }

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

systemctl start nginx \
  && DB_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24` \
  && SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50` \
  && echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc \
  && BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16` \
  && echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc \
  && cp /opt/jumpserver/config_example.yml /opt/jumpserver/config.yml \
  && Server_IP=`ip addr | grep inet | egrep -v '(127.0.0.1|inet6|docker)' | awk '{print $2}' | tr -d "addr:" | head -n 1 | cut -d / -f1` \
  && mysql -uroot -e "create database jumpserver default charset 'utf8';grant all on jumpserver.* to 'jumpserver'@'127.0.0.1' identified by '$DB_PASSWORD';flush privileges;" \
  && sed -i "s/SECRET_KEY:/SECRET_KEY: $SECRET_KEY/g" /opt/jumpserver/config.yml \
  && sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/jumpserver/config.yml \
  && sed -i "s/# DEBUG: true/DEBUG: false/g" /opt/jumpserver/config.yml \
  && sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ERROR/g" /opt/jumpserver/config.yml \
  && sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: false/SESSION_EXPIRE_AT_BROWSER_CLOSE: true/g" /opt/jumpserver/config.yml \
  && sed -i "s/DB_PASSWORD: /DB_PASSWORD: $DB_PASSWORD/g" /opt/jumpserver/config.yml

cd /opt/jumpserver \
  && ./jms start all -d \
  && docker run --name jms_coco -d -p 2222:2222 -p 5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN jumpserver/jms_coco:1.4.8 \
  && docker run --name jms_guacamole -d -p 8081:8081 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN jumpserver/jms_guacamole:1.4.8 \
  && echo -e "\033[31m 你的数据库密码是 $DB_PASSWORD \033[0m" \
  && echo -e "\033[31m 你的SECRET_KEY是 $SECRET_KEY \033[0m" \
  && echo -e "\033[31m 你的BOOTSTRAP_TOKEN是 $BOOTSTRAP_TOKEN \033[0m" \
  && echo -e "\033[31m 你的服务器IP是 $Server_IP \033[0m" \
  && echo -e "\033[31m 请打开浏览器访问 http://$Server_IP 用户名:admin 密码:admin \033[0m"