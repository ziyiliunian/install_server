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

make_mongodb(){
read -p "请输入mongodb文件夹" mongodb_file
cd $mongodb_file
tar -xf mongodb-linux-x86_64-rhel70-3.6.3.tgz 
cd mongodb-linux-x86_64-rhel70-3.6.3/
mkdir /usr/local/mongodb
cp -r bin /usr/local/mongodb/
cd /usr/local/mongodb
mkdir -p etc log data/db
echo '
logpath=/usr/local/mongodb/log/mongodb.log
logappend=true
dbpath=/usr/local/mongodb/data/db
fork=true
' > /usr/local/mongodb/etc/mongodb.conf
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf
}

ip_port_mongodb(){
read -p "请输入连接ip" mongodb_ip
read -p "请输入port" mongodb_port
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf --shutdown
echo '
port=mongodb_port
bind_ip=mongodb_ip
'>> /usr/local/mongodb/etc/mongodb.conf
sed -i "s/mongodb_port/$mongodb_port/" /usr/local/mongodb/etc/mongodb.conf
sed -i "s/mongodb_ip/$mongodb_ip/" /usr/local/mongodb/etc/mongodb.conf
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf
}

ln_mongodb(){
echo "仅会将连接命令添加软链接"
ln -s /usr/local/mongodb/bin/mongo /usr/local/sbin/mongodb
}

alias_mongodb(){
echo 'mstart标示开启mongodb，mstop关闭mongodb'
alias mstop='/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf --shutdown'
alias mstart='/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf '
echo 'alias mstop="/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf --shutdown"' >> /etc/bashrc
echo 'alias mstart="/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf "' >> /etc/bashrc
}

replSet_mongodb(){
read -p "请输入副本集名称" mongodb_repl
repl_mongodb=${mongodb_repl:-rs1}
sed -i '/^$/d' /usr/local/mongodb/etc/mongodb.conf
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf --shutdown
echo "replSet=$repl_mongodb" >> /usr/local/mongodb/etc/mongodb.conf 
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf 
}

#菜单
menu(){
	#clear
	echo "######################################"
	echo "1 安装mongodb"
	echo "2 改ip和port"
	echo "3 添加软链接"
	echo "4 添加启动关闭别名"
	echo "5 启用副本集功能"
	echo "6 退出"
	echo "######################################"
}

#选择
choice(){
	read -p "请选择一个菜单[1-6]:" select
}




while :
do
	menu
	choice
	case $i in 
		 安装mongodb)
			 make_mongodb
			 panduan
		 ;;
		 改ip和port)
			 ip_port_mongodb
			 panduan
		 ;;
		 添加软链接)
			 ln_mongodb
			 panduan
		 ;;
		添加启动关闭别名) 
			 alias_mongodb
			 panduan		
		;;
		启用副本集功能) 
			 replSet_mongodb
			 panduan		
		;;
		退出)
			 echo '888888888888888888888'
			 exit
		;;
		*)
			echo "请输入1、2、3、4、5"
		 ;;	
	esac
done







