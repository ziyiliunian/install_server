#!/bin/bash
#主配置文件/usr/share/backgrounds/default.xml
#壁纸存放目录/usr/share/backgrounds/dr


#更改输入壁纸文件名，并放入壁纸目录中
a=`ls /usr/share/backgrounds/dr | wc -l`
b=$[a-1]
mv $1 /usr/share/backgrounds/dr/bj$a.jpg

#在配置文件中写入更换配置
sed -i  '$d' /usr/share/backgrounds/default.xml > /dev/null

echo '
<transition type="overlay">
<duration>0.1</duration>
' >> /usr/share/backgrounds/default.xml
echo "
<from>/usr/share/backgrounds/dr/bj$b.jpg</from>
<to>/usr/share/backgrounds/dr/bj$a.jpg</to>
</transition>
<static>
<duration>60.0</duration>
<file>/usr/share/backgrounds/dr/bj$a.jpg</file>
</static>
" >> /usr/share/backgrounds/default.xml
echo "</background>" >> /usr/share/backgrounds/default.xml


