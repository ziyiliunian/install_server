#!/bin/bash
#教室pxe安装脚本,仅供参考
#by dr

#判断程序
panduan(){
	if [ $? -eq 0 ];then
		 echo -e "安装$i\033[32m success \033[0m"
	else
		 echo -e "安装$i\033[31m fail \033[0m"
	fi
}

#配置yum源 请根据具体情况改动
yum_server(){
mkdir /var/dvd > /dev/null
echo "/dev/sr0 /var/dvd iso9660 defaults 0 0" >> /etc/fstab
mount -a > /dev/null
rm -rf /etc/yum.repos.d/*.repo
echo '
[development]
name=rhel
baseurl=file:///var/dvd
gpgcheck=0
enabled=1' > /etc/yum.repos.d/dvd.repo
yum clean all > /dev/null
yum repolist > /dev/null
}

#dhcp服务
dhcp_server(){
yum -y install dhcp > /dev/null
echo '
subnet 192.168.4.0 netmask 255.255.255.0{
range 192.168.4.100 192.168.4.200;
option domain-name-servers 8.8.8.8;
option routers 192.168.4.254;
default-lease-time 1000;
max-lease-time 7200;
next-server  local_ip;
filename "pxelinux.0";
}'  >  /etc/dhcp/dhcpd.conf
sed -i  "s/local_ip/$local_ip/" /etc/dhcp/dhcpd.conf
systemctl enable dhcpd > /dev/null
systemctl restart dhcpd
}

#tftp服务
tftp_server(){
yum -y install tftp-server > /dev/null
yum -y install syslinux > /dev/null
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg

#cp /var/dvd/isolinux/linux.cfg /var/lib/tftboot/pxelinux.cfg/default
#chmod +x /var/lib/tftboot/pxelinux.cfg/default
cp /var/dvd/isolinux/vesamenu.c32 /var/dvd/isolinux/splash.png /var/dvd/isolinux/vmlinuz /var/dvd/isolinux/initrd.img /var/lib/tftpboot
systemctl restart tftp
}

#引导文件
boot_server(){
echo '
default vesamenu.c32
timeout 600

display boot.msg

# Clear the screen when exiting the menu, instead of leaving the menu displayed.
# For vesamenu, this means the graphical background is still displayed without
# the menu itself for as long as the screen remains in graphics mode.
menu clear
menu background splash.png
menu title drdrdrdrdrdrdr
menu vshift 8
menu rows 18
menu margin 8
#menu hidden
menu helpmsgrow 15
menu tabmsgrow 13

# Border Area
menu color border * #00000000 #00000000 none

# Selected item
menu color sel 0 #ffffffff #00000000 none

# Title bar
menu color title 0 #ff7ba3d0 #00000000 none

# Press [Tab] message
menu color tabmsg 0 #ff3a6496 #00000000 none

# Unselected menu item
menu color unsel 0 #84b8ffff #00000000 none

# Selected hotkey
menu color hotsel 0 #84b8ffff #00000000 none

# Unselected hotkey
menu color hotkey 0 #ffffffff #00000000 none

# Help text
menu color help 0 #ffffffff #00000000 none

# A scrollbar of some type? Not sure.
menu color scrollbar 0 #ffffffff #ff355594 none

# Timeout msg
menu color timeout 0 #ffffffff #00000000 none
menu color timeout_msg 0 #ffffffff #00000000 none

# Command prompt text
menu color cmdmark 0 #84b8ffff #00000000 none
menu color cmdline 0 #ffffffff #00000000 none

# Do not display the actual menu unless the user presses a key. All that is displayed is a timeout message.

menu tabmsg Press Tab for full configuration options on menu items.

menu separator # insert an empty line
menu separator # insert an empty line

label linux
  menu label ahahhahahahahahahaah 7.4
  menu default
  kernel vmlinuz
  append initrd=initrd.img ks=http://local_ip/ks.cfg
' > /var/lib/tftpboot/pxelinux.cfg/default
sed -i  "s/local_ip/$local_ip/" /var/lib/tftpboot/pxelinux.cfg/default
}


#http_server
http_server(){

systemctl enable tftp > /dev/null

yum -y install httpd > /dev/null

systemctl enable httpd > /dev/null

mkdir /var/www/html/rhel7
echo "/dev/cdrom /var/www/html/rhel7 iso9660 defaults 0 0" >> /etc/fstab
mount -a
systemctl restart httpd
}


#kick文件
kick_server(){
echo '
install
keyboard "us"
rootpw --iscrypted $1$YGuWbFLy$PZFGwJD/ttJKYAqKfiFw90
url --url="http://local_ip/rhel7"
lang zh_CN
firewall --disabled
auth  --useshadow  --passalgo=sha512
text
firstboot --disable
selinux --disabled
network  --bootproto=dhcp --device=eth0
reboot
timezone Asia/Shanghai
bootloader --location=mbr
zerombr
clearpart --all --initlabel
part / --fstype="xfs" --grow --size=1

%post --interpreter=/bin/bash
echo "
[development]
name=rhel
baseurl=ftp://192.168.4.254/rhel7
gpgcheck=0
enabled=1" > /etc/yum.repos.d/dvd.repo
%end

%packages
@base

%end

'  > /var/www/html/ks.cfg
sed -i  "s/local_ip/$local_ip/" /var/www/html/ks.cfg
}



read -p "请输入本机ip(此脚本支持的网段为192.168.4.0):" local_ip
PS3="请选择配置的服务："
select i in "配置yum" "配置DHCP" "配置tftp" "配置http" "写入引导文件" "退出"
do
	case $i in 
		 配置yum)
			 yum_server
			 panduan
		 ;;
		 配置DHCP)
			 dhcp_server
			 panduan
		 ;;
		 配置tftp)
			 tftp_server
			 panduan
		 ;;
		 配置http)
			 http_server
			 panduan
		 ;;
		 写入引导文件)
			 boot_server
			 kick_server
			 panduan
		 ;;
		 退出)
			echo "byebye"
		 	exit
		 ;;	
	esac
done











