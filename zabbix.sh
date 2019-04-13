#!/bin/bash
#
#by dr

#install_zabbix_server
zabbix_monitor(){
mkdir /dr_test
unzip SECURITY.zip -d /dr_test
cd /dr_test
useradd -s /sbin/nologin zabbix

#install_nginx
yum -y install gcc pcre-devel openssl-devel
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
./configure --prefix=/usr/local/nginx
make && make install
cd /dr_test

#install_php_mariadb
yum -y install php php-mysql 
yum -y install mariadb  mariadb-devel mariadb-server 
yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm
yum -y install net-snmp-devel curl-devel libevent-devel-2.0.21-4.el7.x86_64.rpm 

#install_zabbix
tar -xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4/
./configure --enable-server --enable-agent --enable-proxy --with-net-snmp --with-mysql=/usr/bin/mysql_config --with-libcurl > /dev/null
make && make install 

#install_php-devel
cd /dr_test
yum -y install php-bcmath-5.4.16-42.el7.x86_64.rpm php-mbstring-5.4.16-42.el7.x86_64.rpm > /dev/null
yum -y install  php-gd php-xml php-ldap > /dev/null

#install nginx_php
ln -s /usr/local/nginx/sbin/nginx /sbin/
sed -i "/pass the PHP/a }" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a include        fastcgi.conf;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_index  index.php;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_pass   127.0.0.1:9000;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a root           html;" /usr/local/nginx/conf/nginx.conf
sed -i '/pass the PHP/a location ~ \\.php$ {' /usr/local/nginx/conf/nginx.conf

#nginx
sed -i '/http {/a fastcgi_read_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '/http {/a fastcgi_send_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '/http {/a fastcgi_connect_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '/http {/a fastcgi_buffer_size 32k;' /usr/local/nginx/conf/nginx.conf
sed -i '/http {/a fastcgi_buffers 8 16k;' /usr/local/nginx/conf/nginx.conf

#make_mariadb
systemctl restart mariadb
mysql -e 'create database zabbix character set utf8'
mysql -e 'grant all on zabbix.* to zabbix@"localhost" identified by "zabbix"'
cd /dr_test/zabbix-3.4.4/database/mysql
mysql -uzabbix -pzabbix zabbix < schema.sql
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql

#cp_zabbix_php
cd /dr_test/zabbix-3.4.4/frontends/php
cp -r * /usr/local/nginx/html
chmod -R 777 /usr/local/nginx/html

#zabbix_server
sed -i 's/# DBHost=localhost/DBHost=localhost/' /usr/local/etc/zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=zabbix/' /usr/local/etc/zabbix_server.conf
#sed -i '' /usr/local/etc/zabbix_server.conf
#sed -i '' /usr/local/etc/zabbix_server.conf

#zabbix_agent
ip_local=`ifconfig | awk '/inet /{print $2}'  | sed -n '1p'`
#ip_local=`ifconfig | awk '/inet /{print $2}'  | awk 'NR==1{print $1}'`
sed -i "s/^Server=127.0.0.1/Server=127.0.0.1,$ip_local/g"  /usr/local/etc/zabbix_agentd.conf
sed -i "s/^ServerActive=127.0.0.1/ServerActive=127.0.0.1:10051,$ip_local:10051/g"  /usr/local/etc/zabbix_agentd.conf
sed -i "s/^Hostname=Zabbix server/Hostname=$HOSTNAME/g"  /usr/local/etc/zabbix_agentd.conf
sed -i "s/^# UnsafeUserParameters=0/UnsafeUserParameters=1/g"  /usr/local/etc/zabbix_agentd.conf

#php_zabbix
sed -i 's/^post_max_size = 8M/post_max_size = 16M/g' /etc/php.ini
sed -i 's/^max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
sed -i 's/^max_input_time = 60/max_input_time = 300/g' /etc/php.ini
sed -i 's#^;date.timezone =#date.timezone = Asia/Shanghai#g' /etc/php.ini

rm -rf /dr_test
#start_server
nginx
systemctl restart php-fpm
zabbix_server
zabbix_agentd
}

zabbix_server_agentd(){
mkdir /dr_test
unzip SECURITY.zip -d /dr_test
cd /dr_test
useradd -s /sbin/nologin zabbix
yum -y install gcc pcre-devel
yum -y install httpd
systemctl enable httpd

#make_zabbix
tar -xf zabbix-3.4.4.tar.gz 
cd zabbix-3.4.4/
./configure --enable-agent
make install

#zabbix_agentd
read -p "请输入监控服务器ip" local_host
sed -i "s#Server=127.0.0.1#Server=127.0.0.1,$local_host#g"  /usr/local/etc/zabbix_agentd.conf
sed -i "s#ServerActive=127.0.0.1#ServerActive=$local_host:10051#g"  /usr/local/etc/zabbix_agentd.conf
sed -i "s#Hostname=#Hostname=$HOSTNAME#g"  /usr/local/etc/zabbix_agentd.conf
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/g'  /usr/local/etc/zabbix_agentd.conf
sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/g'  /usr/local/etc/zabbix_agentd.conf
sed -i 's%# Include=/usr/local/etc/zabbix_agentd.conf.d/*.conf%Include=/usr/local/etc/zabbix_agentd.conf.d/*.conf%g'  /usr/local/etc/zabbix_agentd.conf

#start_server
rm -rf /dr_test
systemctl start httpd
zabbix_agentd
}

server_agentd(){
killall -9 zabbix_agentd
read -p "请输入监控服务器ip" local_host
sed -i "s/^Server=/# Server=/g" /usr/local/etc/zabbix_agentd.conf
sed -i "s/^# StartAgents=3/StartAgents=0/" /usr/local/etc/zabbix_agentd.conf
sed -i "/^# RefreshActiveChecks=120/RefreshActiveChecks=120/"/usr/local/etc/zabbix_agentd.conf
zabbix_agentd
}



menu(){
clear
echo "########################################"
echo "1. 安装监控主机服务器"
echo "2. 安装被监控主机服务"
echo "3. 将被动模式改为主动模式"
echo "4. 退出"
echo "########################################"
read -p "请选择一个菜单" select
}

read -p  "请保证本脚本和相应tar包均在同一目录,按任意键继续"
while :
 do
	menu
case $select in 
	1)
		echo "默认数据库用户zabbix,密码zabbix,库名zabbix.可以自行修改配置.........."
		echo "5秒后将自动执行安装程序......."
		sleep 5s
		zabbix_monitor			
		;;
	2)
		zabbix_server_agentd
		;;
	3)
		echo "zabbix配置的主机名将为系统的主机名......."
		echo "请确保已安装zabbix被动服务，5秒后自动执行程序......"
		sleep 5s
		server_agentd
		;;
	4)
		echo "byebye"
		exit
		;;
	*)
		echo "错误选项"
esac
done




































