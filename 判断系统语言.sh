#!/bin/bash
#.....
#by dr
echo $LANG | grep -q zh_CN
if [ $? -eq 0 ];then
	 echo "简体中文"
#	 return 0
else
	 echo "其他语言"
#	 return 1
fi
 
