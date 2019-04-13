#!/bin/bash
read -p "请确认在真机上已经挂载光盘，按enter继续" 
read -p "请确认在真机上已经正确启用ftp服务，按enter继续" 

#搭建yum源
echo '
[rhel]
name=rhel
baseurl=ftp://192.168.4.254/rhel7
gpgcheck=0
enabled=1
' > /etc/yum.repos.d/rhel.repo

echo '
[mon]
name=mon
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/MON
gpgcheck=0
[osd]
name=osd
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/OSD
gpgcheck=0
[tools]
name=tools
baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/Tools
gpgcheck=0
' > /etc/yum.repos.d/ceph.repo

#创建hosts文件
echo '
192.168.4.10  client
192.168.4.11     node1
192.168.4.12     node2
192.168.4.13     node3
' >> /etc/hosts

#无密码连接
ssh-keygen   -f /root/.ssh/id_rsa -N ''
for i in 10 11 12 13
  do
	ssh-copy-id 192.168.4.$i
  done

#发送hosts及repo文件
for j in 10 11 12 13 
  do
	scp  /etc/hosts  192.168.4.$j:/etc/	
  done
for k in 10 11 12 13 
  do
	scp  /etc/yum.repos.d/ceph.repo  192.168.4.$k:/etc/yum.repos.d/
  done 
for i in 10 11 12 13 
  do
	scp  /etc/yum.repos.d/rhel.repo  192.168.4.$i:/etc/yum.repos.d/
  done 

#配置时间同步
read -p "请确认在真机上已经搭好NTP服务端，按enter继续" 
echo 'server 192.168.4.254   iburst' >> /etc/chronyd.conf
systemctl restart chronyd

for i in 10 11 12 13 
  do
	scp  /etc/chronyd.conf  192.168.4.$i:/etc/	
  done
read -p "请分别在其余两台机器上重启NTP服务"
echo 'systemctl restart chronyd'
read -p "按enter键继续"

#准备存储磁盘
read -p "请确认在每个虚拟机上另加3块磁盘，每块20G，按enter继续" 

#开始部署集群
#安装ceph部署软件
yum -y install ceph-deploy
mkdir ceph-cluster
#部署ceph集群
cd ceph-cluster/
ceph-deploy new node1 node2 node3
ceph-deploy install node1 node2 node3
ceph-deploy mon create-initial

#准备磁盘分区(node1/2/3)
parted  /dev/vdb  mklabel  gpt
parted  /dev/vdb  mkpart primary  1M  50%
parted  /dev/vdb  mkpart primary  50%  100%
chown  ceph.ceph  /dev/vdb1
chown  ceph.ceph  /dev/vdb2

read -p "请确认在另外两台执行如下命令，按enter继续" 
echo '
parted  /dev/vdb  mklabel  gpt
parted  /dev/vdb  mkpart primary  1M  50%
parted  /dev/vdb  mkpart primary  50%  100%
chown  ceph.ceph  /dev/vdb1
chown  ceph.ceph  /dev/vdb2
'
read -p "执行命令后，按enter继续" 

#做日志盘
echo '
ENV{DEVNAME}=="/dev/vdb1",OWNER="ceph",GROUP="ceph"
ENV{DEVNAME}=="/dev/vdb2",OWNER="ceph",GROUP="ceph"
' > /etc/udev/rules.d/70-vdb.rules
for j in  11 12 13 
  do
	scp  /etc/udev/rules.d/70-vdb.rules  192.168.4.$j:/etc/udev/rules.d/70-vdb.rules	
  done

#初始化清空磁盘数据(node1)
ceph-deploy disk  zap  node1:vdc   node1:vdd
ceph-deploy disk  zap  node2:vdc   node1:vdd
ceph-deploy disk  zap  node3:vdc   node1:vdd

#创建OSD存储空间(node1)
ceph-deploy osd create node1:vdc:/dev/vdb1 node1:vdd:/dev/vdb2  
ceph-deploy osd create node2:vdc:/dev/vdb1 node2:vdd:/dev/vdb2  
ceph-deploy osd create node3:vdc:/dev/vdb1 node3:vdd:/dev/vdb2  

ceph -s

read -p "已部署好ceph集群,按enter退出"
exit










