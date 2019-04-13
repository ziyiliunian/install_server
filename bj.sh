#!/bin/bash
#更改源文件达成目的，其他方法未明
if [ $# -eq 0 ];then
	echo "请添加图片地址"
	exit 2
fi


if [ ! -f $1 ];then
	echo "文件不存在"
	exit 3
fi

echo "提示：若文件不为图像，则背景为黑色"
echo "请稍等``````"
mv   /var/lib/libvirt/images/tedu-wallpaper-2018.png  /var/lib/libvirt/images/tedu-wallpaper-2018-$(date +%Y%m%d).png 
cp $1 /var/lib/libvirt/images/tedu-wallpaper-2018.png
echo "请按F2+ALT,然后输入r即可"
sleep 3s
#startx


