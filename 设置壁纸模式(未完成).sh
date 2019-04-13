#!/bin/bash
#删除原配置文件，新建主配置文件
#by dr
mkdir /usr/share/backgrounds/bground/dr &> /dev/null
dir_default=/usr/share/backgrounds/default.xml
file_default=/usr/share/backgrounds/bground/dr/
#定义头尾函数
head_default(){
	 echo "
<background>
" > $dir_default 
}
tail_default(){
	 echo "
</background>
" >> $dir_default
}

#定义forever_wallpaper函数
forever_wallpaper(){
	head_default
	
	read -p "请输入壁纸的绝对路径" forever_wall
	rm -rf /usr/share/backgrounds/bground/dr/*
	cp $forever_wall $file_default
	static_file=`ls $file_default`
		echo"
			<static>
			<duration>60.0</duration>
			<file>$static_file</file>
			</static>
			" >> $dir_default


	tail_default
}


#定义temporary_wallpaper函数
temporary_wallpaper(){
	head_default

	read -p "请输入预置背景图片文件夹" file_name
	read -p "请输入更换壁纸时间间隔，单位秒" change_time
	rm -rf /usr/share/backgrounds/bground/dr/*
	num=1
    find $file_name -name "*.jpg" |  while read i
	do
	mv $i $file_default$num.jpg
	echo "
		<static>
		<duration>$chang_time</duration>
		<file>$file_default$num.jpg</file>
		</static>
		<transition type=overlay>
        <duration>0.1</duration>
		<from>$file_default$num.jpg</from>
			" >> $dir_default
	let num++
	echo "
		<to>$file_default$num.jpg</to>
		</transition>  " >>$dir_default
	done
	sed -i  's/type=overlay/type="overlay"/ ' $dir_default
	sed -i '/^$/d' $dir_default
	sed -i '$d' $dir_default
	sed -i '$d' $dir_default
	sed -i '$d' $dir_default
	sed -i '$d' $dir_default
	sed -i '$d' $dir_default
	tail_default
}


#定义add_wallpaper函数
add_wallpaper(){
	read -p "请输入图片的绝对路径" add_file
	read -p "请输入更换壁纸时间间隔，单位秒" change_time
	sed -i "s#</background>##" $dir_default
	last_num=`grep '<static>' $dir_default | wc -l`
	add_num=$[last_num+1]
	mv $add_file $dir_default$add_num
	echo "
		nsition type=overlay>
		<duration>0.1</duration>
		<from>$file_default$last_num</from>
		<to>$file_default$add_num</to>
		</transition>
		<static>
		<duration>$chang_time$add_num</duration>
		<file>$</file>
		</static> " >> $dir_default
	sed -i  's/type=overlay/type="overlay"/ ' $dir_default
	tail_default
}




#打印菜单文件
PS3="请选择模式："
select i in "更换固定壁纸" "选择轮换模式" "添加轮换壁纸" "退出" 
do
  case $i in
	更换固定壁纸)
		forever_wallpaper
	;;
	选择轮换模式)
		temporary_wallpaper
	;;
	添加轮换壁纸)
		add_wallpaper
	;;
	退出)
		exit
	;;
	*)
		echo "请选择正确选项"
	;;
  esac
done







