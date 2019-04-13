#!/bin/bash
#注意目录
#by dr

panduan(){
	if [ $? -eq 0 ];then
		 echo -e "安装$i\033[32m success \033[0m"
	else
		 echo -e "安装$i\033[31m fail \033[0m"
	fi
}

install_redis(){
read -p "请输入redis的tar包绝对路径" redis_file
yum -y install gcc gcc-c++ > /dev/null
cd /root
tar -xf $redis_file
cd /root/redis-4.0.8/
make > /dev/null
make install > /dev/null
./utils/install_server.sh 
killall redis-server
/etc/init.d/redis_6379 stop
read -p "请输入端口"  port
read -p "请输入ip"  local_ip
sed -i "s/^bind.*/bind $local_ip/" /etc/redis/6379.conf 
sed -i "s/^port.*/port $port/" /etc/redis/6379.conf
sed -i "s#\$CLIEXEC.*#\$CLIEXEC -h $local_ip -p $port shutdown#"  /etc/init.d/redis_6379
/etc/init.d/redis_6379 start 
#ss -ntlup | grep $port
#redis-cli -h $local_ip -p $port

}

install_nginx(){
read -p "请输入lnmp文件夹路径" nginx_file
cd $nginx_file
tar -xf nginx-1.12.2.tar.gz
yum -y install php-devel-5.4.16-42.el7.x86_64.rpm > /dev/null
yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm > /dev/null
yum -y install pcre-devel zlib-devel php-common > /dev/null
cd nginx-1.12.2
./configure --prefix=/usr/local/nginx > /dev/null
make > /dev/null
make install > /dev/null
sed -i "/pass the PHP/a}" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a include        fastcgi.conf;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_index  index.php;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a fastcgi_pass   127.0.0.1:9000;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a root           html;" /usr/local/nginx/conf/nginx.conf
sed -i "/pass the PHP/a location ~ \.php$ {" /usr/local/nginx/conf/nginx.conf
/usr/local/nginx/sbin/nginx
}

#部署nginx+redis
nginx_redis(){
yum -y install autoconf automake php > /dev/null
read -p "请输入lnmp文件夹路径" nginx_file
cd $nginx_file
tar -xf php-redis-2.2.4.tar.gz
cd phpredis-2.2.4
/usr/bin/phpize
./configure --with-php-config=/usr/bin/php-config
make > /dev/null
php_local=`make install | awk '/^Installing/{print $4}'`
sed -i 's#; extension_dir#extension_dir#' /etc/php.ini
sed -i "s#\.\/#$php_local#" /etc/php.ini
sed -i 's#extension_dir = "ext"#extension = "redis.so"#' /etc/php.ini
php -m | grep -i redis
}

#部署redis集群
redis_cluster(){
killall redis-server
node_port=`awk '/^port/{print $2}' /etc/redis/6379.conf` 
sed -i "s/^# cluster-enabled/cluster-enabled/" /etc/redis/6379.conf
sed -i "s/^# cluster-config-file nodes-6379.conf/cluster-config-file nodes-$node_port.conf/" /etc/redis/6379.conf
sed -i "s/^# cluster-node-timeout 15000/cluster-node-timeout 5000/" /etc/redis/6379.conf
/etc/init.d/redis_6379 start
}

#部署redis集群主机
redis_master(){
read -p "请输入redis文件夹路径" redis_file
read -p "请输入redis-cluter文件夹路径" redis_cluster_file
cd $redis_file
tar -xf redis-4.0.8.tar.gz
cd redis-4.0.8
cd src
mkdir /root/bin
chmod +x redis-trib.rb 
cp redis-trib.rb /root/bin
cd $redis_cluster_file
yum -y install ruby  rubygems > /dev/null
yum -y install ruby-devel-2.0.0.648-30.el7.x86_64.rpm /dev/null
gem install redis-3.2.1.gem >/dev/null
}

#清理redis集群设置
redis_remove(){
node_port=`awk '/^port/{print $2}' /etc/redis/6379.conf` 
sed -i "s/^cluster-enabled/#cluster-enabled/" /etc/redis/6379.conf
sed -i "s/^cluster-config-file nodes-$node_port.conf/#cluster-config-file nodes-$node_port.conf/" /etc/redis/6379.conf
sed -i "s/^cluster-node-timeout 5000/#cluster-node-timeout 5000/" /etc/redis/6379.conf
rm -rf /var/lib/redis/6379/*
/etc/init.d/redis_6379 start						
}

#菜单
menu(){
	#clear
	echo "######################################"
	echo "1 配置redis"
	echo "2 配置nginx"
	echo "3 配置nginx_redis"
	echo "4 配置redis集群"
	echo "5 配置redis集群主机"
	echo "6 清除redis集群设置"
	echo "7 退出"
	echo "######################################"
}

#选择
choice(){
	read -p "请选择一个菜单[1-7]:" select
}

while :
do
	menu
	choice
	case $select in 
		 1)
			 install_redis
			 panduan
		 ;;
		 2)
			 install_nginx
			 panduan
		 ;;
		 3)
			 nginx_redis
			 panduan
		 ;;
		4) 
			 redis_cluster
			 panduan		
		;;
		5)
			 redis_master
		;;
		6)
			 redis_remove
			 panduan
		;;		 
		7)
			echo "byebye"
		 	exit
		 ;;	
		*)
			echo Sorry!
	esac
done









